import { Env, AuthContext } from '../types';
import { authenticate } from '../middleware/auth';
import { json, error } from '../utils/response';

export async function handleEquipment(
  request: Request,
  env: Env,
  path: string,
): Promise<Response> {
  const auth = await authenticate(request, env);
  if (auth instanceof Response) return auth;

  // GET /equipment/ — return all user equipment state
  if (path === '/equipment/' && request.method === 'GET') {
    return getEquipment(env, auth);
  }

  // PUT /equipment/ — bulk upsert (full sync from client)
  if (path === '/equipment/' && request.method === 'PUT') {
    return bulkUpsert(request, env, auth);
  }

  // PATCH /equipment/:id — update single item
  const match = path.match(/^\/equipment\/([a-z0-9_]+)$/);
  if (match && request.method === 'PATCH') {
    return patchItem(request, env, auth, match[1]);
  }

  return error('Not Found', 404);
}

async function getEquipment(env: Env, auth: AuthContext): Promise<Response> {
  const rows = await env.DB.prepare(
    'SELECT equipment_id, owned, shop_url FROM user_equipment WHERE user_id = ?',
  )
    .bind(auth.userId)
    .all();

  const items: Record<string, { owned: boolean; shopUrl: string | null }> = {};
  for (const row of rows.results) {
    items[row.equipment_id as string] = {
      owned: (row.owned as number) === 1,
      shopUrl: (row.shop_url as string) ?? null,
    };
  }

  return json({ items });
}

async function bulkUpsert(
  request: Request,
  env: Env,
  auth: AuthContext,
): Promise<Response> {
  const body = (await request.json()) as {
    items: Record<string, { owned: boolean; shopUrl?: string | null }>;
  };

  if (!body.items || typeof body.items !== 'object') {
    return error('items object is required');
  }

  const entries = Object.entries(body.items);
  if (entries.length > 50) {
    return error('Too many items (max 50)');
  }

  for (const [equipmentId, state] of entries) {
    await env.DB.prepare(`
      INSERT INTO user_equipment (user_id, equipment_id, owned, shop_url, updated_at)
      VALUES (?, ?, ?, ?, datetime('now'))
      ON CONFLICT(user_id, equipment_id) DO UPDATE SET
        owned = excluded.owned,
        shop_url = excluded.shop_url,
        updated_at = datetime('now')
    `)
      .bind(
        auth.userId,
        equipmentId,
        state.owned ? 1 : 0,
        state.shopUrl ?? null,
      )
      .run();
  }

  return json({ synced: entries.length });
}

async function patchItem(
  request: Request,
  env: Env,
  auth: AuthContext,
  equipmentId: string,
): Promise<Response> {
  const body = (await request.json()) as {
    owned?: boolean;
    shopUrl?: string | null;
  };

  // Fetch existing or create defaults
  const existing = await env.DB.prepare(
    'SELECT owned, shop_url FROM user_equipment WHERE user_id = ? AND equipment_id = ?',
  )
    .bind(auth.userId, equipmentId)
    .first();

  const owned = body.owned !== undefined ? body.owned : existing ? (existing.owned as number) === 1 : false;
  const shopUrl = body.shopUrl !== undefined ? body.shopUrl : existing ? (existing.shop_url as string) : null;

  await env.DB.prepare(`
    INSERT INTO user_equipment (user_id, equipment_id, owned, shop_url, updated_at)
    VALUES (?, ?, ?, ?, datetime('now'))
    ON CONFLICT(user_id, equipment_id) DO UPDATE SET
      owned = excluded.owned,
      shop_url = excluded.shop_url,
      updated_at = datetime('now')
  `)
    .bind(auth.userId, equipmentId, owned ? 1 : 0, shopUrl ?? null)
    .run();

  return json({ equipmentId, owned, shopUrl });
}
