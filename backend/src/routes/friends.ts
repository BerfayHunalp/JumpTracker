import { Env, AuthContext } from '../types';
import { authenticate } from '../middleware/auth';
import { json, error } from '../utils/response';
import { createInviteCode, redeemInviteCode } from '../services/invite';

export async function handleFriends(
  request: Request,
  env: Env,
  path: string,
): Promise<Response> {
  const auth = await authenticate(request, env);
  if (auth instanceof Response) return auth;

  if (path === '/friends' && request.method === 'GET') {
    return listFriends(env, auth);
  }
  if (path === '/friends/invite' && request.method === 'POST') {
    return generateInvite(env, auth);
  }
  if (path === '/friends/accept' && request.method === 'POST') {
    return acceptInvite(request, env, auth);
  }

  // DELETE /friends/:id
  const match = path.match(/^\/friends\/([a-f0-9-]+)$/);
  if (match && request.method === 'DELETE') {
    return removeFriend(env, auth, match[1]);
  }

  return error('Not Found', 404);
}

async function listFriends(env: Env, auth: AuthContext): Promise<Response> {
  const friends = await env.DB.prepare(`
    SELECT u.id as userId, u.nickname, u.avatar_index as avatarIndex, f.status, f.created_at as since
    FROM friendships f
    JOIN users u ON u.id = f.friend_id
    WHERE f.user_id = ? AND f.status = 'accepted'
    ORDER BY u.nickname ASC
  `)
    .bind(auth.userId)
    .all();

  return json({ friends: friends.results });
}

async function generateInvite(env: Env, auth: AuthContext): Promise<Response> {
  const invite = await createInviteCode(env, auth.userId);
  return json(invite);
}

async function acceptInvite(
  request: Request,
  env: Env,
  auth: AuthContext,
): Promise<Response> {
  const body = (await request.json()) as { code?: string };
  if (!body.code) return error('code is required');

  const result = await redeemInviteCode(env, body.code, auth.userId);

  if ('error' in result) return error(result.error);

  // Fetch the friend info to return
  const friend = await env.DB.prepare(
    'SELECT id, nickname, avatar_index as avatarIndex FROM users WHERE id = ?',
  )
    .bind(result.inviterUserId)
    .first();

  return json({
    friend: {
      userId: friend?.id,
      nickname: friend?.nickname,
      avatarIndex: friend?.avatarIndex,
      status: 'accepted',
      since: new Date().toISOString(),
    },
  });
}

async function removeFriend(
  env: Env,
  auth: AuthContext,
  friendId: string,
): Promise<Response> {
  // Remove both directions
  await env.DB.batch([
    env.DB.prepare(
      'DELETE FROM friendships WHERE user_id = ? AND friend_id = ?',
    ).bind(auth.userId, friendId),
    env.DB.prepare(
      'DELETE FROM friendships WHERE user_id = ? AND friend_id = ?',
    ).bind(friendId, auth.userId),
  ]);

  return json({ ok: true });
}
