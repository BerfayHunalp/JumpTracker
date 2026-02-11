interface GoogleJwks {
  keys: JsonWebKey[];
}

interface GoogleTokenPayload {
  sub: string;
  email: string;
  name?: string;
  picture?: string;
}

let cachedJwks: GoogleJwks | null = null;
let jwksCachedAt = 0;

async function getGoogleJwks(): Promise<GoogleJwks> {
  const now = Date.now();
  // Cache for 1 hour
  if (cachedJwks && now - jwksCachedAt < 3600000) return cachedJwks;

  const res = await fetch('https://www.googleapis.com/oauth2/v3/certs');
  cachedJwks = (await res.json()) as GoogleJwks;
  jwksCachedAt = now;
  return cachedJwks;
}

function base64urlDecode(str: string): Uint8Array {
  const padded = str.replace(/-/g, '+').replace(/_/g, '/');
  const binStr = atob(padded);
  return Uint8Array.from(binStr, (c) => c.charCodeAt(0));
}

export async function verifyGoogleIdToken(
  idToken: string,
  clientId: string,
): Promise<GoogleTokenPayload | null> {
  const parts = idToken.split('.');
  if (parts.length !== 3) return null;

  const [headerB64, payloadB64, signatureB64] = parts;

  // Decode header to get kid
  const header = JSON.parse(
    new TextDecoder().decode(base64urlDecode(headerB64)),
  ) as { kid: string; alg: string };

  if (header.alg !== 'RS256') return null;

  // Fetch Google's JWKS and find matching key
  const jwks = await getGoogleJwks();
  const jwk = jwks.keys.find((k: any) => k.kid === header.kid);
  if (!jwk) return null;

  // Import the public key
  const key = await crypto.subtle.importKey(
    'jwk',
    jwk,
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['verify'],
  );

  // Verify signature
  const encoder = new TextEncoder();
  const signingInput = encoder.encode(`${headerB64}.${payloadB64}`);
  const signature = base64urlDecode(signatureB64);

  const valid = await crypto.subtle.verify(
    'RSASSA-PKCS1-v1_5',
    key,
    signature,
    signingInput,
  );

  if (!valid) return null;

  // Decode and validate payload
  const payload = JSON.parse(
    new TextDecoder().decode(base64urlDecode(payloadB64)),
  ) as any;

  // Check audience
  if (payload.aud !== clientId) return null;

  // Check expiry
  if (payload.exp < Math.floor(Date.now() / 1000)) return null;

  // Check issuer
  if (payload.iss !== 'accounts.google.com' && payload.iss !== 'https://accounts.google.com') {
    return null;
  }

  return {
    sub: payload.sub,
    email: payload.email,
    name: payload.name,
    picture: payload.picture,
  };
}
