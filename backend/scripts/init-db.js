const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const dbPath = path.join(__dirname, '../data', 'auxivie.db');
const db = new sqlite3.Database(dbPath);

// Ajouter la colonne status à la table documents si elle n'existe pas
db.run(`
  ALTER TABLE documents ADD COLUMN status TEXT DEFAULT 'pending'
`, (err) => {
  if (err && !err.message.includes('duplicate column')) {
    console.error('Erreur lors de l\'ajout de la colonne status:', err);
  } else {
    console.log('✅ Colonne status ajoutée à documents');
  }
});

// Créer la table payments si elle n'existe pas
db.run(`
  CREATE TABLE IF NOT EXISTS payments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    reservationId INTEGER NOT NULL,
    userId INTEGER NOT NULL,
    amount REAL NOT NULL,
    method TEXT,
    status TEXT DEFAULT 'pending',
    createdAt TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (reservationId) REFERENCES reservations(id),
    FOREIGN KEY (userId) REFERENCES users(id)
  )
`, (err) => {
  if (err) {
    console.error('Erreur lors de la création de payments:', err);
  } else {
    console.log('✅ Table payments créée/vérifiée');
  }
});

// Créer la table reviews si elle n'existe pas
db.run(`
  CREATE TABLE IF NOT EXISTS reviews (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    reservationId INTEGER NOT NULL DEFAULT 0,
    userId INTEGER NOT NULL,
    professionalId INTEGER NOT NULL,
    rating INTEGER NOT NULL CHECK(rating >= 1 AND rating <= 5),
    comment TEXT,
    userName TEXT,
    createdAt TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (reservationId) REFERENCES reservations(id),
    FOREIGN KEY (userId) REFERENCES users(id),
    FOREIGN KEY (professionalId) REFERENCES users(id)
  )
`, (err) => {
  if (err) {
    console.error('Erreur lors de la création de reviews:', err);
  } else {
    console.log('✅ Table reviews créée/vérifiée');
    
    // Ajouter la colonne userName si elle n'existe pas
    db.run(`
      ALTER TABLE reviews ADD COLUMN userName TEXT
    `, (alterErr) => {
      if (alterErr && !alterErr.message.includes('duplicate column')) {
        console.error('Erreur lors de l\'ajout de la colonne userName:', alterErr);
      } else if (!alterErr) {
        console.log('✅ Colonne userName ajoutée à reviews');
      }
    });
    
    // S'assurer que reservationId a une valeur par défaut
    db.run(`
      ALTER TABLE reviews ADD COLUMN reservationId INTEGER NOT NULL DEFAULT 0
    `, (alterErr) => {
      if (alterErr && !alterErr.message.includes('duplicate column')) {
        // Si la colonne existe déjà, essayer de modifier sa contrainte
        console.log('⚠️ Colonne reservationId existe déjà');
      } else if (!alterErr) {
        console.log('✅ Colonne reservationId ajoutée/vérifiée');
      }
    });
  }
});

// Créer la table user_badges si elle n'existe pas
db.run(`
  CREATE TABLE IF NOT EXISTS user_badges (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    userId INTEGER NOT NULL,
    badgeType TEXT NOT NULL,
    badgeName TEXT NOT NULL,
    badgeIcon TEXT,
    description TEXT,
    createdAt TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (userId) REFERENCES users(id)
  )
`, (err) => {
  if (err) {
    console.error('Erreur lors de la création de user_badges:', err);
  } else {
    console.log('✅ Table user_badges créée/vérifiée');
  }
});

// Créer la table user_ratings si elle n'existe pas
db.run(`
  CREATE TABLE IF NOT EXISTS user_ratings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    userId INTEGER NOT NULL UNIQUE,
    averageRating REAL NOT NULL DEFAULT 0,
    totalRatings INTEGER NOT NULL DEFAULT 0,
    updatedAt TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (userId) REFERENCES users(id)
  )
`, (err) => {
  if (err) {
    console.error('Erreur lors de la création de user_ratings:', err);
  } else {
    console.log('✅ Table user_ratings créée/vérifiée');
  }
  
  db.close((err) => {
    if (err) {
      console.error('Erreur lors de la fermeture:', err);
    } else {
      console.log('✅ Base de données initialisée avec succès !');
    }
  });
});

