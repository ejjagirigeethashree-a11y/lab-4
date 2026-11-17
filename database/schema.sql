-- ========================================================
-- Lab 4: Registration, Login and JWT
-- SQLite Database Schema Definition
-- ========================================================

CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    password TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Index to ensure performant username lookups
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
