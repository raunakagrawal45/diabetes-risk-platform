import Database from "better-sqlite3";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const db = new Database(path.join(__dirname, "diabetes_platform.db"));

// Enable foreign keys
db.pragma("foreign_keys = ON");

// Initialize database schema
export function initializeDatabase() {
  db.exec(`
    -- Users table
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      email TEXT UNIQUE NOT NULL,
      password_hash TEXT NOT NULL,
      name TEXT,
      created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
      updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
    );

    -- User profiles
    CREATE TABLE IF NOT EXISTS user_profiles (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER UNIQUE NOT NULL,
      age INTEGER,
      gender TEXT,
      height_cm REAL,
      weight_kg REAL,
      family_history_diabetes INTEGER DEFAULT 0,
      created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
      updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    );

    -- Predictions history
    CREATE TABLE IF NOT EXISTS predictions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER,
      input_json TEXT NOT NULL,
      prediction TEXT NOT NULL,
      probability REAL NOT NULL,
      risk_level TEXT NOT NULL,
      confidence REAL,
      recommendations_json TEXT,
      created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
    );

    -- Calculator history
    CREATE TABLE IF NOT EXISTS calculator_history (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER,
      calculator_type TEXT NOT NULL,
      input_json TEXT NOT NULL,
      result_json TEXT NOT NULL,
      created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
    );

    -- Nutrition logs
    CREATE TABLE IF NOT EXISTS nutrition_logs (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER,
      food_name TEXT NOT NULL,
      calories REAL,
      protein REAL,
      carbs REAL,
      fats REAL,
      sugar REAL,
      meal_type TEXT,
      quantity_grams REAL,
      source TEXT,
      created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
    );

    -- Chatbot conversations
    CREATE TABLE IF NOT EXISTS chatbot_sessions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER,
      session_id TEXT UNIQUE NOT NULL,
      started_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
      last_message_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
    );

    CREATE TABLE IF NOT EXISTS chatbot_messages (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      session_id TEXT NOT NULL,
      role TEXT NOT NULL,
      content TEXT NOT NULL,
      context_json TEXT,
      flagged INTEGER DEFAULT 0,
      created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
      FOREIGN KEY (session_id) REFERENCES chatbot_sessions(session_id) ON DELETE CASCADE
    );

    -- Wearable connections
    CREATE TABLE IF NOT EXISTS wearable_connections (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      provider TEXT NOT NULL,
      access_token TEXT,
      refresh_token TEXT,
      expires_at INTEGER,
      connected_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
      last_sync_at INTEGER,
      status TEXT DEFAULT 'active',
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    );

    CREATE TABLE IF NOT EXISTS wearable_events (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      connection_id INTEGER NOT NULL,
      event_type TEXT NOT NULL,
      event_data TEXT NOT NULL,
      event_timestamp INTEGER NOT NULL,
      synced_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
      FOREIGN KEY (connection_id) REFERENCES wearable_connections(id) ON DELETE CASCADE
    );

    -- Educational progress
    CREATE TABLE IF NOT EXISTS educational_progress (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      module_id TEXT NOT NULL,
      completed INTEGER DEFAULT 0,
      progress_percent INTEGER DEFAULT 0,
      last_accessed INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
      UNIQUE(user_id, module_id)
    );

    -- Audit logs
    CREATE TABLE IF NOT EXISTS audit_logs (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER,
      action TEXT NOT NULL,
      resource TEXT NOT NULL,
      details TEXT,
      ip_address TEXT,
      created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
    );

    -- Analytics materialized view (replaces in-memory)
    CREATE TABLE IF NOT EXISTS analytics_snapshots (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      snapshot_type TEXT NOT NULL,
      data_json TEXT NOT NULL,
      created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
    );

    -- Indexes for performance
    CREATE INDEX IF NOT EXISTS idx_predictions_user_id ON predictions(user_id);
    CREATE INDEX IF NOT EXISTS idx_predictions_created_at ON predictions(created_at);
    CREATE INDEX IF NOT EXISTS idx_calculator_history_user_id ON calculator_history(user_id);
    CREATE INDEX IF NOT EXISTS idx_nutrition_logs_user_id ON nutrition_logs(user_id);
    CREATE INDEX IF NOT EXISTS idx_nutrition_logs_created_at ON nutrition_logs(created_at);
    CREATE INDEX IF NOT EXISTS idx_chatbot_sessions_user_id ON chatbot_sessions(user_id);
    CREATE INDEX IF NOT EXISTS idx_chatbot_messages_session_id ON chatbot_messages(session_id);
    CREATE INDEX IF NOT EXISTS idx_wearable_connections_user_id ON wearable_connections(user_id);
    CREATE INDEX IF NOT EXISTS idx_wearable_events_connection_id ON wearable_events(connection_id);
    CREATE INDEX IF NOT EXISTS idx_educational_progress_user_id ON educational_progress(user_id);
    CREATE INDEX IF NOT EXISTS idx_audit_logs_user_id ON audit_logs(user_id);
    CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at ON audit_logs(created_at);
  `);

  console.log("✓ Database initialized successfully");
}

// Initialize database immediately when module loads
initializeDatabase();

// Helper functions for common queries
export const queries = {
  // User operations
  createUser: db.prepare(`
    INSERT INTO users (email, password_hash, name)
    VALUES (?, ?, ?)
  `),

  getUserByEmail: db.prepare(`
    SELECT * FROM users WHERE email = ?
  `),

  getUserById: db.prepare(`
    SELECT * FROM users WHERE id = ?
  `),

  // Prediction operations
  createPrediction: db.prepare(`
    INSERT INTO predictions (user_id, input_json, prediction, probability, risk_level, confidence, recommendations_json)
    VALUES (?, ?, ?, ?, ?, ?, ?)
  `),

  getPredictionsByUserId: db.prepare(`
    SELECT * FROM predictions WHERE user_id = ? ORDER BY created_at DESC LIMIT ?
  `),

  getAllRecentPredictions: db.prepare(`
    SELECT * FROM predictions 
    WHERE created_at > ? 
    ORDER BY created_at DESC 
    LIMIT ?
  `),

  // Calculator operations
  createCalculatorHistory: db.prepare(`
    INSERT INTO calculator_history (user_id, calculator_type, input_json, result_json)
    VALUES (?, ?, ?, ?)
  `),

  getCalculatorHistory: db.prepare(`
    SELECT * FROM calculator_history WHERE user_id = ? ORDER BY created_at DESC LIMIT 50
  `),

  // Nutrition operations
  createNutritionLog: db.prepare(`
    INSERT INTO nutrition_logs (user_id, food_name, calories, protein, carbs, fats, sugar, meal_type, quantity_grams, source)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  `),

  getNutritionLogsByUserId: db.prepare(`
    SELECT * FROM nutrition_logs WHERE user_id = ? ORDER BY created_at DESC LIMIT ?
  `),

  // Chatbot operations
  createChatSession: db.prepare(`
    INSERT INTO chatbot_sessions (user_id, session_id)
    VALUES (?, ?)
  `),

  createChatMessage: db.prepare(`
    INSERT INTO chatbot_messages (session_id, role, content, context_json, flagged)
    VALUES (?, ?, ?, ?, ?)
  `),

  getChatMessages: db.prepare(`
    SELECT * FROM chatbot_messages WHERE session_id = ? ORDER BY created_at ASC
  `),

  updateSessionLastMessage: db.prepare(`
    UPDATE chatbot_sessions SET last_message_at = strftime('%s', 'now') WHERE session_id = ?
  `),

  // Nutrition scan logging (used by food scanner)
  logNutrition: db.prepare(`
    INSERT INTO nutrition_logs (user_id, food_name, calories, protein, carbs, fats, sugar, meal_type, source)
    VALUES (?, ?, ?, ?, ?, ?, ?, 'scan', 'food_scanner')
  `),

  // Audit operations
  createAuditLog: db.prepare(`
    INSERT INTO audit_logs (user_id, action, resource, details, ip_address)
    VALUES (?, ?, ?, ?, ?)
  `),
};

export default db;
