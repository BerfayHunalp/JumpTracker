import { Env, AuthContext } from '../types';
import { authenticate } from '../middleware/auth';
import { json, error } from '../utils/response';
import { refreshLeaderboardCache } from '../services/leaderboard';

interface SyncSessionPayload {
  session: {
    id: string;
    startedAt: string;
    endedAt?: string;
    resortName?: string;
    totalJumps: number;
    maxAirtimeMs: number;
    totalVerticalM: number;
  };
  jumps: Array<{
    id: string;
    runId: string;
    takeoffTimestampUs: number;
    landingTimestampUs: number;
    airtimeMs: number;
    distanceM: number;
    heightM: number;
    speedKmh: number;
    landingGForce: number;
    latTakeoff?: number;
    lonTakeoff?: number;
    latLanding?: number;
    lonLanding?: number;
    altitudeTakeoff?: number;
    trickLabel?: string;
  }>;
}

export async function handleSync(
  request: Request,
  env: Env,
  path: string,
): Promise<Response> {
  const auth = await authenticate(request, env);
  if (auth instanceof Response) return auth;

  if (path === '/sync/sessions' && request.method === 'POST') {
    return syncSessions(request, env, auth);
  }
  if (path === '/sync/sessions' && request.method === 'GET') {
    return listSyncedSessions(request, env, auth);
  }

  // GET /sync/sessions/:id
  const match = path.match(/^\/sync\/sessions\/([a-f0-9-]+)$/);
  if (match && request.method === 'GET') {
    return getSyncedSession(env, auth, match[1]);
  }

  return error('Not Found', 404);
}

async function syncSessions(
  request: Request,
  env: Env,
  auth: AuthContext,
): Promise<Response> {
  const body = (await request.json()) as { sessions: SyncSessionPayload[] };

  if (!body.sessions || !Array.isArray(body.sessions)) {
    return error('sessions array is required');
  }

  const synced: string[] = [];
  const errors: Array<{ id: string; error: string }> = [];

  for (const entry of body.sessions) {
    try {
      const { session, jumps } = entry;

      // Compute total score
      const totalScore = jumps.reduce((sum, j) => {
        return sum + (j.airtimeMs / 100) * 40 + j.heightM * 30 + j.distanceM * 10;
      }, 0);

      // Upsert session
      await env.DB.prepare(`
        INSERT INTO synced_sessions (id, user_id, started_at, ended_at, resort_name, total_jumps, max_airtime_ms, total_vertical_m, total_score)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT(id) DO UPDATE SET
          ended_at = excluded.ended_at,
          total_jumps = excluded.total_jumps,
          max_airtime_ms = excluded.max_airtime_ms,
          total_vertical_m = excluded.total_vertical_m,
          total_score = excluded.total_score,
          synced_at = datetime('now')
      `)
        .bind(
          session.id,
          auth.userId,
          session.startedAt,
          session.endedAt ?? null,
          session.resortName ?? null,
          session.totalJumps,
          session.maxAirtimeMs,
          session.totalVerticalM,
          totalScore,
        )
        .run();

      // Upsert jumps
      for (const jump of jumps) {
        const score =
          (jump.airtimeMs / 100) * 40 + jump.heightM * 30 + jump.distanceM * 10;

        await env.DB.prepare(`
          INSERT INTO synced_jumps (id, session_id, user_id, run_id, takeoff_timestamp_us, landing_timestamp_us, airtime_ms, distance_m, height_m, speed_kmh, landing_g_force, lat_takeoff, lon_takeoff, lat_landing, lon_landing, altitude_takeoff, score, trick_label)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
          ON CONFLICT(id) DO UPDATE SET
            score = excluded.score,
            trick_label = excluded.trick_label
        `)
          .bind(
            jump.id,
            session.id,
            auth.userId,
            jump.runId,
            jump.takeoffTimestampUs,
            jump.landingTimestampUs,
            jump.airtimeMs,
            jump.distanceM,
            jump.heightM,
            jump.speedKmh,
            jump.landingGForce,
            jump.latTakeoff ?? null,
            jump.lonTakeoff ?? null,
            jump.latLanding ?? null,
            jump.lonLanding ?? null,
            jump.altitudeTakeoff ?? null,
            score,
            jump.trickLabel ?? null,
          )
          .run();
      }

      synced.push(session.id);
    } catch (e) {
      errors.push({ id: entry.session.id, error: String(e) });
    }
  }

  // Refresh leaderboard cache in the background
  await refreshLeaderboardCache(env, auth.userId);

  return json({ synced, errors });
}

async function listSyncedSessions(
  request: Request,
  env: Env,
  auth: AuthContext,
): Promise<Response> {
  const url = new URL(request.url);
  const page = parseInt(url.searchParams.get('page') || '1');
  const limit = Math.min(parseInt(url.searchParams.get('limit') || '20'), 50);
  const offset = (page - 1) * limit;

  const sessions = await env.DB.prepare(
    'SELECT * FROM synced_sessions WHERE user_id = ? ORDER BY started_at DESC LIMIT ? OFFSET ?',
  )
    .bind(auth.userId, limit, offset)
    .all();

  const countRow = await env.DB.prepare(
    'SELECT COUNT(*) as total FROM synced_sessions WHERE user_id = ?',
  )
    .bind(auth.userId)
    .first();

  return json({
    sessions: sessions.results,
    total: countRow?.total ?? 0,
  });
}

async function getSyncedSession(
  env: Env,
  auth: AuthContext,
  sessionId: string,
): Promise<Response> {
  const session = await env.DB.prepare(
    'SELECT * FROM synced_sessions WHERE id = ? AND user_id = ?',
  )
    .bind(sessionId, auth.userId)
    .first();

  if (!session) return error('Session not found', 404);

  const jumps = await env.DB.prepare(
    'SELECT * FROM synced_jumps WHERE session_id = ? ORDER BY takeoff_timestamp_us ASC',
  )
    .bind(sessionId)
    .all();

  return json({ session, jumps: jumps.results });
}
