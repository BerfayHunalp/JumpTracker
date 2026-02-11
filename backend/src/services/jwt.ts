export interface JwtPayload {
  sub: string;
  email: string;
  iat: number;
  exp: number;
}

function base64url(data: Uint8Array): string {
  const binStr = Array.from(data, (b) => String.fromCharCode(b)).join('');
  return btoa(binStr).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}

function base64urlEncode(str: string): string {
  const encoder = new TextEncoder();
  return base64url(encoder.encode(str));
}

function base64urlDecode(str: string): Uint8Array {
  const padded = str.replace(/-/g, '+').replace(/_/g, '/');
  const binStr = atob(padded);
  return Uint8Array.from(binStr, (c) => c.charCodeAt(0));
}

async function getKey(secret: string): Promise<CryptoKey> {
  const encoder = new TextEncoder();
  return crypto.subtle.importKey(
    'raw',
    encoder.encode(secret),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign', 'verify'],
  );
}

export async function signJwt(
  userId: string,
  email: string,
  secret: string,
  expiresInDays = 7,
): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const header = base64urlEncode(JSON.stringify({ alg: 'HS256', typ: 'JWT' }));
  const payload = base64urlEncode(
    JSON.stringify({
      sub: userId,
      email,
      iat: now,
      exp: now + expiresInDays * 86400,
    }),
  );

  const signingInput = `${header}.${payload}`;
  const key = await getKey(secret);
  const encoder = new TextEncoder();
  const signature = await crypto.subtle.sign('HMAC', key, encoder.encode(signingInput));

  return `${signingInput}.${base64url(new Uint8Array(signature))}`;
}

export async function verifyJwt(
  token: string,
  secret: string,
): Promise<JwtPayload | null> {
  const parts = token.split('.');
  if (parts.length !== 3) return null;

  const [header, payload, sig] = parts;
  const signingInput = `${header}.${payload}`;
  const key = await getKey(secret);
  const encoder = new TextEncoder();

  const signatureBytes = base64urlDecode(sig);
  const valid = await crypto.subtle.verify(
    'HMAC',
    key,
    signatureBytes,
    encoder.encode(signingInput),
  );

  if (!valid) return null;

  const decoded = JSON.parse(
    new TextDecoder().decode(base64urlDecode(payload)),
  ) as JwtPayload;

  // Check expiration
  if (decoded.exp < Math.floor(Date.now() / 1000)) return null;

  return decoded;
}
