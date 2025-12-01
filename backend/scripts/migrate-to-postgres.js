const sqlite3 = require('sqlite3').verbose();
const { Client } = require('pg');
const path = require('path');
require('dotenv').config();

// Configuration PostgreSQL
const pgConfig = {
  host: process.env.PG_HOST || 'localhost',
  port: process.env.PG_PORT || 5432,
  database: process.env.PG_DATABASE || 'auxivie',
  user: process.env.PG_USER || 'postgres',
  password: process.env.PG_PASSWORD || '',
};

// Chemin vers la base SQLite
const sqlitePath = path.join(__dirname, '../data/auxivie.db');

console.log('🔄 Migration de SQLite vers PostgreSQL...');

// Connexion SQLite
const sqliteDb = new sqlite3.Database(sqlitePath, (err) => {
  if (err) {
    console.error('❌ Erreur connexion SQLite:', err);
    process.exit(1);
  }
  console.log('✅ Connecté à SQLite');
});

// Connexion PostgreSQL
const pgClient = new Client(pgConfig);

pgClient.connect()
  .then(() => {
    console.log('✅ Connecté à PostgreSQL');
    return migrateData();
  })
  .catch((err) => {
    console.error('❌ Erreur connexion PostgreSQL:', err);
    console.log('\n💡 Assurez-vous que PostgreSQL est installé et configuré.');
    console.log('💡 Installez le package: npm install pg');
    process.exit(1);
  });

async function migrateData() {
  try {
    // Créer les tables PostgreSQL (schéma similaire à SQLite)
    await createPostgresTables();
    
    // Migrer les données
    await migrateTable('users');
    await migrateTable('reservations');
    await migrateTable('messages');
    await migrateTable('documents');
    await migrateTable('payments');
    await migrateTable('user_badges');
    await migrateTable('user_ratings');
    await migrateTable('reviews');
    
    console.log('\n✅ Migration terminée avec succès!');
    pgClient.end();
    sqliteDb.close();
  } catch (error) {
    console.error('❌ Erreur lors de la migration:', error);
    pgClient.end();
    sqliteDb.close();
    process.exit(1);
  }
}

async function createPostgresTables() {
  console.log('\n📋 Création des tables PostgreSQL...');
  
  const queries = [
    `CREATE TABLE IF NOT EXISTS users (
      id SERIAL PRIMARY KEY,
      name TEXT NOT NULL,
      email TEXT NOT NULL UNIQUE,
      password TEXT NOT NULL,
      phone TEXT,
      categorie TEXT NOT NULL,
      ville TEXT,
      tarif REAL,
      experience INTEGER,
      photo TEXT,
      userType TEXT NOT NULL,
      besoin TEXT,
      preference TEXT,
      mission TEXT,
      particularite TEXT,
      createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )`,
    `CREATE TABLE IF NOT EXISTS reservations (
      id SERIAL PRIMARY KEY,
      userId INTEGER NOT NULL,
      professionnelId INTEGER NOT NULL,
      date TEXT NOT NULL,
      heure TEXT NOT NULL,
      status TEXT DEFAULT 'pending',
      createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (userId) REFERENCES users(id),
      FOREIGN KEY (professionnelId) REFERENCES users(id)
    )`,
    `CREATE TABLE IF NOT EXISTS messages (
      id SERIAL PRIMARY KEY,
      senderId INTEGER NOT NULL,
      receiverId INTEGER NOT NULL,
      content TEXT NOT NULL,
      timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      isRead INTEGER DEFAULT 0,
      FOREIGN KEY (senderId) REFERENCES users(id),
      FOREIGN KEY (receiverId) REFERENCES users(id)
    )`,
    `CREATE TABLE IF NOT EXISTS documents (
      id SERIAL PRIMARY KEY,
      userId INTEGER NOT NULL,
      type TEXT NOT NULL,
      path TEXT NOT NULL,
      status TEXT DEFAULT 'pending',
      createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (userId) REFERENCES users(id)
    )`,
    `CREATE TABLE IF NOT EXISTS payments (
      id SERIAL PRIMARY KEY,
      reservationId INTEGER NOT NULL,
      userId INTEGER NOT NULL,
      amount REAL NOT NULL,
      method TEXT,
      status TEXT DEFAULT 'pending',
      createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (reservationId) REFERENCES reservations(id),
      FOREIGN KEY (userId) REFERENCES users(id)
    )`,
    `CREATE TABLE IF NOT EXISTS user_badges (
      id SERIAL PRIMARY KEY,
      userId INTEGER NOT NULL,
      badgeType TEXT NOT NULL,
      badgeName TEXT NOT NULL,
      badgeIcon TEXT,
      description TEXT,
      createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (userId) REFERENCES users(id)
    )`,
    `CREATE TABLE IF NOT EXISTS user_ratings (
      id SERIAL PRIMARY KEY,
      userId INTEGER NOT NULL UNIQUE,
      averageRating REAL NOT NULL DEFAULT 0,
      totalRatings INTEGER NOT NULL DEFAULT 0,
      updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (userId) REFERENCES users(id)
    )`,
    `CREATE TABLE IF NOT EXISTS reviews (
      id SERIAL PRIMARY KEY,
      reservationId INTEGER NOT NULL DEFAULT 0,
      userId INTEGER NOT NULL,
      professionalId INTEGER NOT NULL,
      rating INTEGER NOT NULL CHECK(rating >= 1 AND rating <= 5),
      comment TEXT,
      userName TEXT,
      createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (reservationId) REFERENCES reservations(id),
      FOREIGN KEY (userId) REFERENCES users(id),
      FOREIGN KEY (professionalId) REFERENCES users(id)
    )`,
  ];
  
  for (const query of queries) {
    await pgClient.query(query);
  }
  
  console.log('✅ Tables créées');
}

function migrateTable(tableName) {
  return new Promise((resolve, reject) => {
    console.log(`\n📦 Migration de la table: ${tableName}`);
    
    sqliteDb.all(`SELECT * FROM ${tableName}`, async (err, rows) => {
      if (err) {
        if (err.message.includes('no such table')) {
          console.log(`⚠️  Table ${tableName} n'existe pas dans SQLite, ignorée`);
          return resolve();
        }
        return reject(err);
      }
      
      if (rows.length === 0) {
        console.log(`ℹ️  Table ${tableName} est vide`);
        return resolve();
      }
      
      // Vider la table PostgreSQL avant migration
      await pgClient.query(`TRUNCATE TABLE ${tableName} CASCADE`);
      
      // Insérer les données
      for (const row of rows) {
        const columns = Object.keys(row).join(', ');
        const values = Object.values(row);
        const placeholders = values.map((_, i) => `$${i + 1}`).join(', ');
        
        try {
          await pgClient.query(
            `INSERT INTO ${tableName} (${columns}) VALUES (${placeholders})`,
            values
          );
        } catch (error) {
          console.error(`⚠️  Erreur insertion ligne dans ${tableName}:`, error.message);
        }
      }
      
      console.log(`✅ ${rows.length} lignes migrées pour ${tableName}`);
      resolve();
    });
  });
}

