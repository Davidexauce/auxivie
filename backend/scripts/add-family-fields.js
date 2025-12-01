const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const dbPath = path.join(__dirname, '../data', 'auxivie.db');
const db = new sqlite3.Database(dbPath);

console.log('🔄 Ajout des colonnes famille à la table users...');

// Ajouter les colonnes si elles n'existent pas
const columns = [
  { name: 'besoin', type: 'TEXT' },
  { name: 'preference', type: 'TEXT' },
  { name: 'mission', type: 'TEXT' },
  { name: 'particularite', type: 'TEXT' },
];

columns.forEach((column) => {
  db.run(
    `ALTER TABLE users ADD COLUMN ${column.name} ${column.type}`,
    (err) => {
      if (err && !err.message.includes('duplicate column')) {
        console.error(`❌ Erreur lors de l'ajout de la colonne ${column.name}:`, err);
      } else if (!err) {
        console.log(`✅ Colonne ${column.name} ajoutée`);
      }
    }
  );
});

// Fermer la base de données après un court délai
setTimeout(() => {
  db.close((err) => {
    if (err) {
      console.error('❌ Erreur lors de la fermeture:', err);
    } else {
      console.log('✅ Migration terminée !');
    }
  });
}, 1000);

