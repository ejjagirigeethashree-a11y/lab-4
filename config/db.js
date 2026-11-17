const path = require('path');
const fs = require('fs');
const sqlite3 = require('sqlite3');
const { open } = require('sqlite');
require('dotenv').config();

const dbPath = process.env.DB_FILE_PATH || path.join(__dirname, '..', 'database', 'users.db');

// Ensure parent database directory exists
const dbDir = path.dirname(path.resolve(dbPath));
if (!fs.existsSync(dbDir)) {
  fs.mkdirSync(dbDir, { recursive: true });
}

let dbInstance = null;

const initializeDatabase = async () => {
  if (dbInstance) {
    return dbInstance;
  }

  dbInstance = await open({
    filename: path.resolve(dbPath),
    driver: sqlite3.Database,
  });

  // Enable foreign key constraints
  await dbInstance.run('PRAGMA foreign_keys = ON;');

  // Create users table if it does not already exist
  await dbInstance.exec(`
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT UNIQUE NOT NULL,
      name TEXT NOT NULL,
      password TEXT NOT NULL,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );
  `);

  console.log(`[Database] SQLite connected successfully at: ${path.resolve(dbPath)}`);
  return dbInstance;
};

const getDatabase = async () => {
  if (!dbInstance) {
    return await initializeDatabase();
  }
  return dbInstance;
};

module.exports = {
  initializeDatabase,
  getDatabase,
};
