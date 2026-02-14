-- Emergency contacts (max 2 per user)
CREATE TABLE emergency_contacts (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(id),
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  created_at TEXT DEFAULT (datetime('now'))
);
CREATE INDEX idx_emergency_contacts_user ON emergency_contacts(user_id);

-- Live location shares
CREATE TABLE live_shares (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(id),
  token TEXT NOT NULL UNIQUE,
  started_at TEXT DEFAULT (datetime('now')),
  stopped_at TEXT,
  last_lat REAL,
  last_lon REAL,
  last_alt REAL,
  last_speed REAL,
  last_bearing REAL,
  last_updated_at TEXT
);
CREATE INDEX idx_live_shares_token ON live_shares(token);
CREATE INDEX idx_live_shares_user ON live_shares(user_id);
