-- Users
CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  google_sub TEXT UNIQUE,
  apple_sub TEXT UNIQUE,
  email TEXT,
  nickname TEXT NOT NULL,
  avatar_index INTEGER DEFAULT 0,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Friendships (bidirectional)
CREATE TABLE IF NOT EXISTS friendships (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(id),
  friend_id TEXT NOT NULL REFERENCES users(id),
  status TEXT NOT NULL DEFAULT 'accepted',
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE(user_id, friend_id)
);

-- Invite codes for friend invites
CREATE TABLE IF NOT EXISTS invite_codes (
  code TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(id),
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  expires_at TEXT NOT NULL,
  used_by TEXT REFERENCES users(id),
  used_at TEXT
);

-- Synced sessions (mirrors local Sessions table)
CREATE TABLE IF NOT EXISTS synced_sessions (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(id),
  started_at TEXT NOT NULL,
  ended_at TEXT,
  resort_name TEXT,
  total_jumps INTEGER DEFAULT 0,
  max_airtime_ms REAL DEFAULT 0,
  total_vertical_m REAL DEFAULT 0,
  total_score REAL DEFAULT 0,
  synced_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Synced jumps (mirrors local Jumps table)
CREATE TABLE IF NOT EXISTS synced_jumps (
  id TEXT PRIMARY KEY,
  session_id TEXT NOT NULL REFERENCES synced_sessions(id),
  user_id TEXT NOT NULL REFERENCES users(id),
  run_id TEXT NOT NULL,
  takeoff_timestamp_us INTEGER NOT NULL,
  landing_timestamp_us INTEGER NOT NULL,
  airtime_ms REAL NOT NULL,
  distance_m REAL NOT NULL,
  height_m REAL NOT NULL,
  speed_kmh REAL NOT NULL,
  landing_g_force REAL NOT NULL,
  lat_takeoff REAL,
  lon_takeoff REAL,
  lat_landing REAL,
  lon_landing REAL,
  altitude_takeoff REAL,
  score REAL NOT NULL
);

-- Leaderboard cache (materialized aggregation)
CREATE TABLE IF NOT EXISTS leaderboard_cache (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(id),
  period TEXT NOT NULL,
  total_score REAL DEFAULT 0,
  total_jumps INTEGER DEFAULT 0,
  best_jump_score REAL DEFAULT 0,
  best_airtime_ms REAL DEFAULT 0,
  session_count INTEGER DEFAULT 0,
  updated_at TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE(user_id, period)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_friendships_user ON friendships(user_id, status);
CREATE INDEX IF NOT EXISTS idx_friendships_friend ON friendships(friend_id, status);
CREATE INDEX IF NOT EXISTS idx_invite_codes_user ON invite_codes(user_id);
CREATE INDEX IF NOT EXISTS idx_synced_sessions_user ON synced_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_synced_sessions_started ON synced_sessions(started_at);
CREATE INDEX IF NOT EXISTS idx_synced_jumps_session ON synced_jumps(session_id);
CREATE INDEX IF NOT EXISTS idx_synced_jumps_user ON synced_jumps(user_id);
CREATE INDEX IF NOT EXISTS idx_synced_jumps_score ON synced_jumps(score DESC);
CREATE INDEX IF NOT EXISTS idx_leaderboard_period_score ON leaderboard_cache(period, total_score DESC);
