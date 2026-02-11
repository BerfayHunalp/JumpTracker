interface AppleJwks {
  keys: JsonWebKey[];
}

interface AppleTokenPayload {
  sub: string;
  email: string;
}

let cachedAppleJwks: AppleJwks | null = null;
let appleJwksCachedAt = 0;

async function getAppleJwks(): Promise<AppleJwks> {
  const now = Date.now();
  if (cachedAppleJwks && now - appleJwksCachedAt < 3600000) return cachedAppleJwks;

  const res = await fetch('https://appleid.apple.com/auth/keys');
  cachedAppleJwks = (await res.json()) as AppleJwks;
  appleJwksCachedAt = now;
  return cachedAppleJwks;
}

function base64urlDecode(str: string): Uint8Array {
  const padded = str.replace(/-/g, '+').replace(/_/g, '/');
  const binStr = atob(padded);
  return Uint8Array.from(binStr, (c) => c.charCodeAt(0));
}

export async function verifyAppleIdToken(
  idToken: string,
  bundleId: string,
): Promise<AppleTokenPayload | null> {
  const parts = idToken.split('.');
  if (parts.length !== 3) return null;

  const [headerB64, payloadB64, signatureB64] = parts;

  const header = JSON.parse(
    new TextDecoder().decode(base64urlDecode(headerB64)),
  ) as { kid: string; alg: string };

  if (header.alg !== 'RS256') return null;

  const jwks = await getAppleJwks();
  const jwk = jwks.keys.find((k: any) => k.kid === header.kid);
  if (!jwk) return null;

  const key = await crypto.subtle.importKey(
    'jwk',
    jwk,
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['verify'],
  );

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

  const payload = JSON.parse(
    new TextDecoder().decode(base64urlDecode(payloadB64)),
  ) as any;

  // Validate audience (bundle ID)
  if (payload.aud !== bundleId) return null;

  // Check expiry
  if (payload.exp < Math.floor(Date.now() / 1000)) return null;

  // Check issuer
  if (payload.iss !== 'https://appleid.apple.com') return null;

  return {
    sub: payload.sub,
    email: payload.email,
  };
}
