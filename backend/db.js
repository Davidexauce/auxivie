// Module de connexion MySQL
const mysql = require('mysql2/promise');
require('dotenv').config({ path: process.env.NODE_ENV === 'production' ? '.env.production' : '.env' });

// Configuration de la connexion MySQL
const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'auxivie',
  port: process.env.DB_PORT || 3306,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  enableKeepAlive: true,
  keepAliveInitialDelay: 0
};

// Créer le pool de connexions
const pool = mysql.createPool(dbConfig);

// Fonction pour tester la connexion
async function testConnection() {
  try {
    const connection = await pool.getConnection();
    console.log('✅ Connexion MySQL établie');
    connection.release();
    return true;
  } catch (error) {
    console.error('❌ Erreur connexion MySQL:', error.message);
    return false;
  }
}

// Fonction helper pour exécuter des requêtes
async function query(sql, params = []) {
  try {
    const [results] = await pool.execute(sql, params);
    return results;
  } catch (error) {
    console.error('Erreur SQL:', error.message);
    console.error('Requête:', sql);
    console.error('Paramètres:', params);
    throw error;
  }
}

// Fonction helper pour obtenir une seule ligne
async function get(sql, params = []) {
  const results = await query(sql, params);
  return results.length > 0 ? results[0] : null;
}

// Fonction helper pour obtenir toutes les lignes
async function all(sql, params = []) {
  return await query(sql, params);
}

// Fonction helper pour exécuter une requête (INSERT, UPDATE, DELETE)
async function run(sql, params = []) {
  const results = await query(sql, params);
  return {
    lastID: results.insertId,
    changes: results.affectedRows
  };
}

// Initialiser les tables si nécessaire (pour compatibilité avec SQLite)
async function initializeTables() {
  try {
    await testConnection();
    await run(`
      CREATE TABLE IF NOT EXISTS reports (
        id INT AUTO_INCREMENT PRIMARY KEY,
        userId INT NOT NULL,
        reportedUserId INT NULL,
        reservationId INT NULL,
        type VARCHAR(50) NOT NULL,
        message TEXT NOT NULL,
        status VARCHAR(20) DEFAULT 'open',
        createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
        resolvedAt DATETIME NULL,
        INDEX idx_userId (userId),
        INDEX idx_reportedUserId (reportedUserId)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    `);
    console.log('✅ Base de données MySQL initialisée');
  } catch (error) {
    console.error('❌ Erreur initialisation tables:', error);
  }
}

// Exporter
module.exports = {
  pool,
  query,
  get,
  all,
  run,
  testConnection,
  initializeTables
};

