import { Env } from '../types';

export async function refreshLeaderboardCache(
  env: Env,
  userId: string,
): Promise<void> {
  const now = new Date();

  // Calculate week start (Monday 00:00 UTC)
  const dayOfWeek = now.getUTCDay();
  const mondayOffset = dayOfWeek === 0 ? 6 : dayOfWeek - 1;
  const weekStart = new Date(now);
  weekStart.setUTCDate(now.getUTCDate() - mondayOffset);
  weekStart.setUTCHours(0, 0, 0, 0);

  // Calculate season start (Dec 1 of current or previous year)
  const month = now.getUTCMonth(); // 0-indexed
  const year = now.getUTCFullYear();
  const seasonYear = month >= 11 ? year : year - 1; // Dec=11
  const seasonStart = new Date(Date.UTC(seasonYear, 11, 1)); // Dec 1

  await Promise.all([
    updatePeriod(env, userId, 'week', weekStart.toISOString()),
    updatePeriod(env, userId, 'season', seasonStart.toISOString()),
    updatePeriod(env, userId, 'alltime', null),
  ]);
}

async function updatePeriod(
  env: Env,
  userId: string,
  period: string,
  sinceDate: string | null,
): Promise<void> {
  const dateFilter = sinceDate ? 'AND ss.started_at >= ?' : '';
  const bindings = sinceDate ? [userId, sinceDate] : [userId];

  const stats = await env.DB.prepare(`
    SELECT
      COALESCE(SUM(ss.total_score), 0) as total_score,
      COALESCE(SUM(ss.total_jumps), 0) as total_jumps,
      COUNT(ss.id) as session_count
    FROM synced_sessions ss
    WHERE ss.user_id = ? ${dateFilter}
  `)
    .bind(...bindings)
    .first();

  const bestJump = await env.DB.prepare(`
    SELECT
      COALESCE(MAX(sj.score), 0) as best_jump_score,
      COALESCE(MAX(sj.airtime_ms), 0) as best_airtime_ms
    FROM synced_jumps sj
    JOIN synced_sessions ss ON ss.id = sj.session_id
    WHERE sj.user_id = ? ${dateFilter}
  `)
    .bind(...bindings)
    .first();

  const cacheId = `${userId}:${period}`;

  await env.DB.prepare(`
    INSERT INTO leaderboard_cache (id, user_id, period, total_score, total_jumps, best_jump_score, best_airtime_ms, session_count, updated_at)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, datetime('now'))
    ON CONFLICT(user_id, period) DO UPDATE SET
      total_score = excluded.total_score,
      total_jumps = excluded.total_jumps,
      best_jump_score = excluded.best_jump_score,
      best_airtime_ms = excluded.best_airtime_ms,
      session_count = excluded.session_count,
      updated_at = excluded.updated_at
  `)
    .bind(
      cacheId,
      userId,
      period,
      stats?.total_score ?? 0,
      stats?.total_jumps ?? 0,
      bestJump?.best_jump_score ?? 0,
      bestJump?.best_airtime_ms ?? 0,
      stats?.session_count ?? 0,
    )
    .run();
}
