-- User equipment state (owned / shop URL)
CREATE TABLE IF NOT EXISTS user_equipment (
  user_id TEXT NOT NULL REFERENCES users(id),
  equipment_id TEXT NOT NULL,
  owned INTEGER NOT NULL DEFAULT 0,
  shop_url TEXT,
  updated_at TEXT NOT NULL DEFAULT (datetime('now')),
  PRIMARY KEY (user_id, equipment_id)
);

CREATE INDEX IF NOT EXISTS idx_user_equipment_user ON user_equipment(user_id);
