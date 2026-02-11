import { Env } from '../types';

const CHARS = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // no 0/O/1/I confusion

export function generateCode(): string {
  const bytes = new Uint8Array(8);
  crypto.getRandomValues(bytes);
  return Array.from(bytes, (b) => CHARS[b % CHARS.length]).join('');
}

export async function createInviteCode(
  env: Env,
  userId: string,
): Promise<{ code: string; link: string; expiresAt: string }> {
  const code = generateCode();
  const expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString();

  await env.DB.prepare(
    'INSERT INTO invite_codes (code, user_id, expires_at) VALUES (?, ?, ?)',
  )
    .bind(code, userId, expiresAt)
    .run();

  return {
    code,
    link: `${env.INVITE_BASE_URL}/${code}`,
    expiresAt,
  };
}

export async function redeemInviteCode(
  env: Env,
  code: string,
  redeemerUserId: string,
): Promise<{ inviterUserId: string } | { error: string }> {
  const invite = await env.DB.prepare(
    "SELECT * FROM invite_codes WHERE code = ? AND used_by IS NULL AND expires_at > datetime('now')",
  )
    .bind(code)
    .first();

  if (!invite) return { error: 'Invalid or expired invite code' };

  const inviterUserId = invite.user_id as string;

  if (inviterUserId === redeemerUserId) {
    return { error: 'Cannot use your own invite code' };
  }

  // Check if already friends
  const existing = await env.DB.prepare(
    'SELECT id FROM friendships WHERE user_id = ? AND friend_id = ?',
  )
    .bind(inviterUserId, redeemerUserId)
    .first();

  if (existing) return { error: 'Already friends' };

  // Create bidirectional friendship
  const id1 = crypto.randomUUID();
  const id2 = crypto.randomUUID();

  await env.DB.batch([
    env.DB.prepare(
      "INSERT INTO friendships (id, user_id, friend_id, status) VALUES (?, ?, ?, 'accepted')",
    ).bind(id1, inviterUserId, redeemerUserId),
    env.DB.prepare(
      "INSERT INTO friendships (id, user_id, friend_id, status) VALUES (?, ?, ?, 'accepted')",
    ).bind(id2, redeemerUserId, inviterUserId),
    env.DB.prepare(
      "UPDATE invite_codes SET used_by = ?, used_at = datetime('now') WHERE code = ?",
    ).bind(redeemerUserId, code),
  ]);

  return { inviterUserId };
}
