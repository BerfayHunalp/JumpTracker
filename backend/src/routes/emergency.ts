import { Env, AuthContext } from '../types';
import { authenticate } from '../middleware/auth';
import { json, error } from '../utils/response';

export async function handleEmergency(
  request: Request,
  env: Env,
  path: string,
): Promise<Response> {
  // ── Public endpoints (no auth) ──────────────────────────────────────
  const liveMatch = path.match(/^\/emergency\/live\/([a-zA-Z0-9]+)$/);
  if (liveMatch && request.method === 'GET') {
    return getLiveData(env, liveMatch[1]);
  }

  const mapMatch = path.match(/^\/emergency\/map\/([a-zA-Z0-9]+)$/);
  if (mapMatch && request.method === 'GET') {
    return getMapPage(env, mapMatch[1]);
  }

  // ── Authed endpoints ────────────────────────────────────────────────
  const auth = await authenticate(request, env);
  if (auth instanceof Response) return auth;

  // Contacts CRUD
  if (path === '/emergency/contacts' && request.method === 'GET') {
    return listContacts(env, auth);
  }
  if (path === '/emergency/contacts' && request.method === 'POST') {
    return addContact(request, env, auth);
  }
  const deleteMatch = path.match(/^\/emergency\/contacts\/([a-f0-9-]+)$/);
  if (deleteMatch && request.method === 'DELETE') {
    return deleteContact(env, auth, deleteMatch[1]);
  }

  // Live sharing
  if (path === '/emergency/start' && request.method === 'POST') {
    return startSharing(env, auth);
  }
  if (path === '/emergency/update' && request.method === 'POST') {
    return updateLocation(request, env, auth);
  }
  if (path === '/emergency/stop' && request.method === 'POST') {
    return stopSharing(env, auth);
  }

  return error('Not Found', 404);
}

// ── Contacts ────────────────────────────────────────────────────────────

async function listContacts(env: Env, auth: AuthContext): Promise<Response> {
  const rows = await env.DB.prepare(
    'SELECT id, name, phone, created_at as createdAt FROM emergency_contacts WHERE user_id = ? ORDER BY created_at ASC',
  )
    .bind(auth.userId)
    .all();

  return json({ contacts: rows.results });
}

async function addContact(
  request: Request,
  env: Env,
  auth: AuthContext,
): Promise<Response> {
  const body = (await request.json()) as { name?: string; phone?: string };
  if (!body.name || !body.phone) {
    return error('name and phone are required');
  }

  // Max 2 contacts
  const count = await env.DB.prepare(
    'SELECT COUNT(*) as cnt FROM emergency_contacts WHERE user_id = ?',
  )
    .bind(auth.userId)
    .first<{ cnt: number }>();

  if (count && count.cnt >= 2) {
    return error('Maximum 2 emergency contacts allowed');
  }

  const id = crypto.randomUUID();
  await env.DB.prepare(
    'INSERT INTO emergency_contacts (id, user_id, name, phone) VALUES (?, ?, ?, ?)',
  )
    .bind(id, auth.userId, body.name, body.phone)
    .run();

  return json({ id, name: body.name, phone: body.phone });
}

async function deleteContact(
  env: Env,
  auth: AuthContext,
  contactId: string,
): Promise<Response> {
  await env.DB.prepare(
    'DELETE FROM emergency_contacts WHERE id = ? AND user_id = ?',
  )
    .bind(contactId, auth.userId)
    .run();

  return json({ ok: true });
}

// ── Live sharing ────────────────────────────────────────────────────────

function generateToken(): string {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  let token = '';
  const bytes = new Uint8Array(12);
  crypto.getRandomValues(bytes);
  for (const b of bytes) {
    token += chars[b % chars.length];
  }
  return token;
}

async function startSharing(env: Env, auth: AuthContext): Promise<Response> {
  // Stop any existing active share first
  await env.DB.prepare(
    "UPDATE live_shares SET stopped_at = datetime('now') WHERE user_id = ? AND stopped_at IS NULL",
  )
    .bind(auth.userId)
    .run();

  const id = crypto.randomUUID();
  const token = generateToken();

  await env.DB.prepare(
    'INSERT INTO live_shares (id, user_id, token) VALUES (?, ?, ?)',
  )
    .bind(id, auth.userId, token)
    .run();

  const baseUrl = new URL('https://ski-tracker-api.apexdiligence.workers.dev');
  const shareUrl = `${baseUrl.origin}/emergency/map/${token}`;

  return json({ token, shareUrl });
}

async function updateLocation(
  request: Request,
  env: Env,
  auth: AuthContext,
): Promise<Response> {
  const body = (await request.json()) as {
    lat?: number;
    lon?: number;
    alt?: number;
    speed?: number;
    bearing?: number;
  };

  if (body.lat == null || body.lon == null) {
    return error('lat and lon are required');
  }

  const result = await env.DB.prepare(
    `UPDATE live_shares
     SET last_lat = ?, last_lon = ?, last_alt = ?, last_speed = ?, last_bearing = ?, last_updated_at = datetime('now')
     WHERE user_id = ? AND stopped_at IS NULL`,
  )
    .bind(
      body.lat,
      body.lon,
      body.alt ?? null,
      body.speed ?? null,
      body.bearing ?? null,
      auth.userId,
    )
    .run();

  return json({ ok: true });
}

async function stopSharing(env: Env, auth: AuthContext): Promise<Response> {
  await env.DB.prepare(
    "UPDATE live_shares SET stopped_at = datetime('now') WHERE user_id = ? AND stopped_at IS NULL",
  )
    .bind(auth.userId)
    .run();

  return json({ ok: true });
}

// ── Public: live data ───────────────────────────────────────────────────

async function getLiveData(env: Env, token: string): Promise<Response> {
  const share = await env.DB.prepare(
    `SELECT ls.last_lat, ls.last_lon, ls.last_alt, ls.last_speed, ls.last_bearing,
            ls.last_updated_at, ls.stopped_at, u.nickname
     FROM live_shares ls
     JOIN users u ON u.id = ls.user_id
     WHERE ls.token = ?`,
  )
    .bind(token)
    .first<{
      last_lat: number | null;
      last_lon: number | null;
      last_alt: number | null;
      last_speed: number | null;
      last_bearing: number | null;
      last_updated_at: string | null;
      stopped_at: string | null;
      nickname: string | null;
    }>();

  if (!share) return error('Share not found', 404);

  return json({
    lat: share.last_lat,
    lon: share.last_lon,
    alt: share.last_alt,
    speed: share.last_speed,
    bearing: share.last_bearing,
    updatedAt: share.last_updated_at,
    userName: share.nickname ?? 'Skier',
    active: share.stopped_at === null,
  });
}

// ── Public: map HTML page ───────────────────────────────────────────────

async function getMapPage(env: Env, token: string): Promise<Response> {
  // Verify the token exists
  const share = await env.DB.prepare(
    'SELECT id FROM live_shares WHERE token = ?',
  )
    .bind(token)
    .first();

  if (!share) return error('Share not found', 404);

  const apiBase = 'https://ski-tracker-api.apexdiligence.workers.dev';

  const html = `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Live Location — BH Motion</title>
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; background: #0f1726; color: #fff; }
  #map { width: 100%; height: 70vh; }
  .info-bar { padding: 16px; background: #1b2a4a; }
  .info-bar h2 { font-size: 18px; margin-bottom: 8px; }
  .info-bar .detail { color: #a0b0cc; font-size: 14px; margin-top: 4px; }
  .info-bar .speed { color: #4FC3F7; font-weight: 600; }
  .info-bar .status { display: inline-block; padding: 3px 10px; border-radius: 12px; font-size: 12px; font-weight: 700; margin-left: 8px; }
  .status.active { background: rgba(129,199,132,0.2); color: #81C784; }
  .status.stopped { background: rgba(239,83,80,0.2); color: #EF5350; }
  .info-bar .updated { color: #667; font-size: 12px; margin-top: 8px; }
  .waiting { display: flex; align-items: center; justify-content: center; height: 70vh; color: #667; font-size: 16px; }
</style>
</head>
<body>
<div id="map-container"><div class="waiting" id="waiting">Waiting for location data...</div></div>
<div class="info-bar">
  <h2 id="userName">Loading...</h2>
  <div class="detail">
    <span id="statusBadge" class="status active">LIVE</span>
    <span class="speed" id="speedText"></span>
  </div>
  <div class="detail" id="altText"></div>
  <div class="updated" id="updatedText"></div>
</div>
<script>
  const TOKEN = '${token}';
  const API = '${apiBase}/emergency/live/' + TOKEN;
  let map, marker, circle, mapReady = false;

  function initMap(lat, lon) {
    document.getElementById('waiting').remove();
    const mapDiv = document.createElement('div');
    mapDiv.id = 'map';
    document.getElementById('map-container').appendChild(mapDiv);
    map = L.map('map').setView([lat, lon], 15);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; OpenStreetMap'
    }).addTo(map);
    marker = L.marker([lat, lon]).addTo(map);
    circle = L.circle([lat, lon], { radius: 30, color: '#4FC3F7', fillOpacity: 0.15 }).addTo(map);
    mapReady = true;
  }

  async function poll() {
    try {
      const res = await fetch(API);
      const d = await res.json();
      document.getElementById('userName').textContent = d.userName || 'Skier';

      const badge = document.getElementById('statusBadge');
      if (d.active) {
        badge.textContent = 'LIVE';
        badge.className = 'status active';
      } else {
        badge.textContent = 'STOPPED';
        badge.className = 'status stopped';
      }

      if (d.lat != null && d.lon != null) {
        if (!mapReady) initMap(d.lat, d.lon);
        marker.setLatLng([d.lat, d.lon]);
        circle.setLatLng([d.lat, d.lon]);
        map.panTo([d.lat, d.lon]);
      }

      if (d.speed != null) {
        document.getElementById('speedText').textContent = ' — ' + (d.speed * 3.6).toFixed(0) + ' km/h';
      }
      if (d.alt != null) {
        document.getElementById('altText').textContent = 'Altitude: ' + Math.round(d.alt) + ' m';
      }
      if (d.updatedAt) {
        const ago = Math.round((Date.now() - new Date(d.updatedAt + 'Z').getTime()) / 1000);
        document.getElementById('updatedText').textContent = 'Updated ' + (ago < 60 ? ago + 's ago' : Math.round(ago / 60) + 'min ago');
      }
    } catch (e) {
      console.error('Poll error:', e);
    }
  }

  poll();
  setInterval(poll, 15000);
</script>
</body>
</html>`;

  return new Response(html, {
    status: 200,
    headers: {
      'Content-Type': 'text/html; charset=utf-8',
      'Cache-Control': 'no-cache',
    },
  });
}
