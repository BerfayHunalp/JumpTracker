import { Env } from '../types';
import { json, error } from '../utils/response';
import { signJwt, verifyJwt } from '../services/jwt';
import { verifyGoogleIdToken } from '../services/google-auth';
import { verifyAppleIdToken } from '../services/apple-auth';

export async function handleAuth(
  request: Request,
  env: Env,
  path: string,
): Promise<Response> {
  if (path === '/auth/google' && request.method === 'POST') {
    return handleGoogleAuth(request, env);
  }
  if (path === '/auth/apple' && request.method === 'POST') {
    return handleAppleAuth(request, env);
  }
  if (path === '/auth/register' && request.method === 'POST') {
    return handleEmailRegister(request, env);
  }
  if (path === '/auth/login' && request.method === 'POST') {
    return handleEmailLogin(request, env);
  }
  if (path === '/auth/refresh' && request.method === 'POST') {
    return handleRefresh(request, env);
  }
  return error('Not Found', 404);
}

async function handleGoogleAuth(request: Request, env: Env): Promise<Response> {
  const body = (await request.json()) as { idToken?: string };
  if (!body.idToken) return error('idToken is required');

  const googleUser = await verifyGoogleIdToken(body.idToken, env.GOOGLE_CLIENT_ID);
  if (!googleUser) return error('Invalid Google ID token', 401);

  return upsertUserAndRespond(env, {
    providerColumn: 'google_sub',
    providerSub: googleUser.sub,
    email: googleUser.email,
    name: googleUser.name,
  });
}

async function handleAppleAuth(request: Request, env: Env): Promise<Response> {
  const body = (await request.json()) as {
    idToken?: string;
    firstName?: string;
    lastName?: string;
  };
  if (!body.idToken) return error('idToken is required');

  const appleUser = await verifyAppleIdToken(body.idToken, env.APPLE_BUNDLE_ID);
  if (!appleUser) return error('Invalid Apple ID token', 401);

  const name =
    body.firstName && body.lastName
      ? `${body.firstName} ${body.lastName}`
      : body.firstName || undefined;

  return upsertUserAndRespond(env, {
    providerColumn: 'apple_sub',
    providerSub: appleUser.sub,
    email: appleUser.email,
    name,
  });
}

async function handleRefresh(request: Request, env: Env): Promise<Response> {
  const authHeader = request.headers.get('Authorization');
  if (!authHeader?.startsWith('Bearer ')) {
    return error('Missing Authorization header', 401);
  }

  const token = authHeader.slice(7);
  const payload = await verifyJwt(token, env.JWT_SECRET);
  if (!payload) return error('Invalid or expired token', 401);

  // Issue fresh token
  const newToken = await signJwt(payload.sub, payload.email, env.JWT_SECRET);

  // Fetch current user
  const user = await env.DB.prepare('SELECT * FROM users WHERE id = ?')
    .bind(payload.sub)
    .first();

  if (!user) return error('User not found', 404);

  return json({ token: newToken, user: formatUser(user) });
}

async function upsertUserAndRespond(
  env: Env,
  opts: {
    providerColumn: string;
    providerSub: string;
    email: string;
    name?: string;
  },
): Promise<Response> {
  const { providerColumn, providerSub, email, name } = opts;

  // Check if user exists with this provider
  const existing = await env.DB.prepare(
    `SELECT * FROM users WHERE ${providerColumn} = ?`,
  )
    .bind(providerSub)
    .first();

  if (existing) {
    const token = await signJwt(
      existing.id as string,
      existing.email as string,
      env.JWT_SECRET,
    );
    return json({ token, user: formatUser(existing), isNewUser: false });
  }

  // Check if user exists with this email (link accounts)
  if (email) {
    const emailUser = await env.DB.prepare(
      'SELECT * FROM users WHERE email = ?',
    )
      .bind(email)
      .first();

    if (emailUser) {
      // Link provider to existing account
      await env.DB.prepare(
        `UPDATE users SET ${providerColumn} = ?, updated_at = datetime('now') WHERE id = ?`,
      )
        .bind(providerSub, emailUser.id)
        .run();

      const token = await signJwt(
        emailUser.id as string,
        emailUser.email as string,
        env.JWT_SECRET,
      );
      return json({ token, user: formatUser(emailUser), isNewUser: false });
    }
  }

  // Create new user
  const userId = crypto.randomUUID();
  const nickname = name || 'Skier';

  await env.DB.prepare(
    `INSERT INTO users (id, ${providerColumn}, email, nickname) VALUES (?, ?, ?, ?)`,
  )
    .bind(userId, providerSub, email, nickname)
    .run();

  const newUser = await env.DB.prepare('SELECT * FROM users WHERE id = ?')
    .bind(userId)
    .first();

  const token = await signJwt(userId, email, env.JWT_SECRET);
  return json({ token, user: formatUser(newUser!), isNewUser: true });
}

async function hashPassword(password: string): Promise<string> {
  const encoder = new TextEncoder();
  const salt = crypto.getRandomValues(new Uint8Array(16));
  const keyMaterial = await crypto.subtle.importKey(
    'raw', encoder.encode(password), 'PBKDF2', false, ['deriveBits'],
  );
  const derived = await crypto.subtle.deriveBits(
    { name: 'PBKDF2', salt, iterations: 100000, hash: 'SHA-256' },
    keyMaterial, 256,
  );
  const hashBytes = new Uint8Array(derived);
  const saltHex = Array.from(salt, b => b.toString(16).padStart(2, '0')).join('');
  const hashHex = Array.from(hashBytes, b => b.toString(16).padStart(2, '0')).join('');
  return `${saltHex}:${hashHex}`;
}

async function verifyPassword(password: string, stored: string): Promise<boolean> {
  const [saltHex, hashHex] = stored.split(':');
  const salt = new Uint8Array(saltHex.match(/.{2}/g)!.map(b => parseInt(b, 16)));
  const encoder = new TextEncoder();
  const keyMaterial = await crypto.subtle.importKey(
    'raw', encoder.encode(password), 'PBKDF2', false, ['deriveBits'],
  );
  const derived = await crypto.subtle.deriveBits(
    { name: 'PBKDF2', salt, iterations: 100000, hash: 'SHA-256' },
    keyMaterial, 256,
  );
  const computedHex = Array.from(new Uint8Array(derived), b => b.toString(16).padStart(2, '0')).join('');
  return computedHex === hashHex;
}

async function handleEmailRegister(request: Request, env: Env): Promise<Response> {
  const body = (await request.json()) as { email?: string; password?: string; nickname?: string };
  if (!body.email || !body.password) return error('Email and password are required');
  if (body.password.length < 6) return error('Password must be at least 6 characters');

  const email = body.email.toLowerCase().trim();

  // Check if email already exists
  const existing = await env.DB.prepare('SELECT id FROM users WHERE email = ?').bind(email).first();
  if (existing) return error('An account with this email already exists', 409);

  const userId = crypto.randomUUID();
  const nickname = body.nickname || email.split('@')[0];
  const passwordHash = await hashPassword(body.password);

  await env.DB.prepare(
    'INSERT INTO users (id, email, nickname, password_hash) VALUES (?, ?, ?, ?)',
  ).bind(userId, email, nickname, passwordHash).run();

  const user = await env.DB.prepare('SELECT * FROM users WHERE id = ?').bind(userId).first();
  const token = await signJwt(userId, email, env.JWT_SECRET);

  return json({ token, user: formatUser(user!), isNewUser: true });
}

async function handleEmailLogin(request: Request, env: Env): Promise<Response> {
  const body = (await request.json()) as { email?: string; password?: string };
  if (!body.email || !body.password) return error('Email and password are required');

  const email = body.email.toLowerCase().trim();

  const user = await env.DB.prepare('SELECT * FROM users WHERE email = ?').bind(email).first();
  if (!user || !user.password_hash) return error('Invalid email or password', 401);

  const valid = await verifyPassword(body.password, user.password_hash as string);
  if (!valid) return error('Invalid email or password', 401);

  const token = await signJwt(user.id as string, email, env.JWT_SECRET);
  return json({ token, user: formatUser(user), isNewUser: false });
}

function formatUser(row: Record<string, unknown>) {
  return {
    id: row.id,
    email: row.email,
    nickname: row.nickname,
    avatarIndex: row.avatar_index,
    createdAt: row.created_at,
  };
}
