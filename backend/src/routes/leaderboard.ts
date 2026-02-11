import { Env, AuthContext } from '../types';
import { authenticate } from '../middleware/auth';
import { json, error } from '../utils/response';

export async function handleLeaderboard(
  request: Request,
  env: Env,
  path: string,
): Promise<Response> {
  const auth = await authenticate(request, env);
  if (auth instanceof Response) return auth;

  const url = new URL(request.url);
  const period = url.searchParams.get('period') || 'week';

  if (!['week', 'season', 'alltime'].includes(period)) {
    return error('Invalid period. Use: week, season, alltime');
  }

  if (path === '/leaderboard/friends' && request.method === 'GET') {
    return friendLeaderboard(env, auth, period);
  }
  if (path === '/leaderboard/global' && request.method === 'GET') {
    return globalLeaderboard(env, auth, period);
  }

  return error('Not Found', 404);
}

async function friendLeaderboard(
  env: Env,
  auth: AuthContext,
  period: string,
): Promise<Response> {
  // Get leaderboard entries for friends + self
  const entries = await env.DB.prepare(`
    SELECT
      lc.user_id as userId,
      u.nickname,
      u.avatar_index as avatarIndex,
      lc.total_score as totalScore,
      lc.total_jumps as totalJumps,
      lc.best_jump_score as bestJumpScore,
      lc.best_airtime_ms as bestAirtimeMs,
      lc.session_count as sessionCount
    FROM leaderboard_cache lc
    JOIN users u ON u.id = lc.user_id
    WHERE lc.period = ?
      AND lc.user_id IN (
        SELECT friend_id FROM friendships WHERE user_id = ? AND status = 'accepted'
        UNION ALL SELECT ?
      )
    ORDER BY lc.total_score DESC
  `)
    .bind(period, auth.userId, auth.userId)
    .all();

  return formatLeaderboard(entries.results, auth.userId);
}

async function globalLeaderboard(
  env: Env,
  auth: AuthContext,
  period: string,
): Promise<Response> {
  const entries = await env.DB.prepare(`
    SELECT
      lc.user_id as userId,
      u.nickname,
      u.avatar_index as avatarIndex,
      lc.total_score as totalScore,
      lc.total_jumps as totalJumps,
      lc.best_jump_score as bestJumpScore,
      lc.best_airtime_ms as bestAirtimeMs,
      lc.session_count as sessionCount
    FROM leaderboard_cache lc
    JOIN users u ON u.id = lc.user_id
    WHERE lc.period = ?
    ORDER BY lc.total_score DESC
    LIMIT 50
  `)
    .bind(period)
    .all();

  // Check if user is in top 50, if not get their rank
  const friendIds = await env.DB.prepare(
    "SELECT friend_id FROM friendships WHERE user_id = ? AND status = 'accepted'",
  )
    .bind(auth.userId)
    .all();

  const friendIdSet = new Set(friendIds.results.map((r) => r.friend_id as string));

  let myRank = -1;
  const formatted = entries.results.map((entry, i) => {
    const isMe = entry.userId === auth.userId;
    if (isMe) myRank = i + 1;
    return {
      rank: i + 1,
      ...entry,
      isMe,
      isFriend: friendIdSet.has(entry.userId as string),
    };
  });

  // If user not in top 50, get their rank
  if (myRank === -1) {
    const rankRow = await env.DB.prepare(`
      SELECT COUNT(*) + 1 as rank
      FROM leaderboard_cache
      WHERE period = ? AND total_score > (
        SELECT COALESCE(total_score, 0) FROM leaderboard_cache WHERE user_id = ? AND period = ?
      )
    `)
      .bind(period, auth.userId, period)
      .first();
    myRank = (rankRow?.rank as number) ?? -1;
  }

  return json({ entries: formatted, myRank });
}

function formatLeaderboard(
  results: Record<string, unknown>[],
  currentUserId: string,
): Response {
  let myRank = -1;
  const entries = results.map((entry, i) => {
    const isMe = entry.userId === currentUserId;
    if (isMe) myRank = i + 1;
    return {
      rank: i + 1,
      ...entry,
      isMe,
      isFriend: !isMe,
    };
  });

  return json({ entries, myRank });
}
