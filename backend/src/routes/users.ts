import { Env, AuthContext } from '../types';
import { authenticate } from '../middleware/auth';
import { json, error } from '../utils/response';

export async function handleUsers(
  request: Request,
  env: Env,
  path: string,
): Promise<Response> {
  const auth = await authenticate(request, env);
  if (auth instanceof Response) return auth;

  if (path === '/users/me' && request.method === 'GET') {
    return getMe(env, auth);
  }
  if (path === '/users/me' && request.method === 'PATCH') {
    return updateMe(request, env, auth);
  }

  // GET /users/:id
  const match = path.match(/^\/users\/([a-f0-9-]+)$/);
  if (match && request.method === 'GET') {
    return getPublicProfile(env, match[1]);
  }

  return error('Not Found', 404);
}

async function getMe(env: Env, auth: AuthContext): Promise<Response> {
  const user = await env.DB.prepare('SELECT * FROM users WHERE id = ?')
    .bind(auth.userId)
    .first();

  if (!user) return error('User not found', 404);

  // Aggregate stats
  const stats = await env.DB.prepare(`
    SELECT
      COALESCE(SUM(total_jumps), 0) as totalJumps,
      COUNT(*) as totalSessions,
      COALESCE(SUM(total_score), 0) as totalScore,
      COALESCE(MAX(max_airtime_ms), 0) as bestAirtimeMs
    FROM synced_sessions WHERE user_id = ?
  `)
    .bind(auth.userId)
    .first();

  const bestJump = await env.DB.prepare(`
    SELECT MAX(score) as bestJumpScore
    FROM synced_jumps WHERE user_id = ?
  `)
    .bind(auth.userId)
    .first();

  return json({
    user: formatUser(user),
    stats: {
      totalSessions: stats?.totalSessions ?? 0,
      totalJumps: stats?.totalJumps ?? 0,
      totalScore: stats?.totalScore ?? 0,
      bestJumpScore: bestJump?.bestJumpScore ?? 0,
      bestAirtimeMs: stats?.bestAirtimeMs ?? 0,
    },
  });
}

async function updateMe(
  request: Request,
  env: Env,
  auth: AuthContext,
): Promise<Response> {
  const body = (await request.json()) as {
    nickname?: string;
    avatarIndex?: number;
  };

  const updates: string[] = [];
  const values: (string | number)[] = [];

  if (body.nickname !== undefined) {
    const nick = body.nickname.trim().slice(0, 20);
    if (nick.length < 1) return error('Nickname must be at least 1 character');
    updates.push('nickname = ?');
    values.push(nick);
  }

  if (body.avatarIndex !== undefined) {
    if (body.avatarIndex < 0 || body.avatarIndex > 95) {
      return error('Invalid avatar index');
    }
    updates.push('avatar_index = ?');
    values.push(body.avatarIndex);
  }

  if (updates.length === 0) return error('No fields to update');

  updates.push("updated_at = datetime('now')");
  values.push(auth.userId);

  await env.DB.prepare(
    `UPDATE users SET ${updates.join(', ')} WHERE id = ?`,
  )
    .bind(...values)
    .run();

  const user = await env.DB.prepare('SELECT * FROM users WHERE id = ?')
    .bind(auth.userId)
    .first();

  return json({ user: formatUser(user!) });
}

async function getPublicProfile(env: Env, userId: string): Promise<Response> {
  const user = await env.DB.prepare(
    'SELECT id, nickname, avatar_index, created_at FROM users WHERE id = ?',
  )
    .bind(userId)
    .first();

  if (!user) return error('User not found', 404);

  const stats = await env.DB.prepare(`
    SELECT
      COALESCE(SUM(total_jumps), 0) as totalJumps,
      COUNT(*) as totalSessions,
      COALESCE(SUM(total_score), 0) as totalScore,
      COALESCE(MAX(max_airtime_ms), 0) as bestAirtimeMs
    FROM synced_sessions WHERE user_id = ?
  `)
    .bind(userId)
    .first();

  return json({
    user: {
      id: user.id,
      nickname: user.nickname,
      avatarIndex: user.avatar_index,
    },
    stats: {
      totalSessions: stats?.totalSessions ?? 0,
      totalJumps: stats?.totalJumps ?? 0,
      totalScore: stats?.totalScore ?? 0,
      bestAirtimeMs: stats?.bestAirtimeMs ?? 0,
    },
  });
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
