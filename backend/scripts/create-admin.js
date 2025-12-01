const sqlite3 = require('sqlite3').verbose();
const bcrypt = require('bcryptjs');
const path = require('path');

const dbPath = path.join(__dirname, '../data/auxivie.db');
const db = new sqlite3.Database(dbPath);

const adminEmail = 'admin@auxivie.com';
const adminPassword = 'admin123'; // Mot de passe par défaut

bcrypt.hash(adminPassword, 10, (err, hash) => {
  if (err) {
    console.error('Erreur lors du hashage:', err);
    db.close();
    return;
  }

  // Vérifier si l'admin existe déjà
  db.get('SELECT id FROM users WHERE email = ?', [adminEmail], (err, row) => {
    if (err) {
      console.error('Erreur:', err);
      db.close();
      return;
    }

    if (row) {
      // Mettre à jour le mot de passe
      db.run(
        'UPDATE users SET password = ? WHERE email = ?',
        [hash, adminEmail],
        function(err) {
          if (err) {
            console.error('Erreur lors de la mise à jour:', err);
          } else {
            console.log('✅ Mot de passe admin mis à jour avec succès !');
            console.log('📧 Email:', adminEmail);
            console.log('🔑 Mot de passe:', adminPassword);
          }
          db.close();
        }
      );
    } else {
      // Créer l'admin
      db.run(
        `INSERT INTO users (name, email, password, categorie, userType) 
         VALUES (?, ?, ?, ?, ?)`,
        ['Administrateur', adminEmail, hash, 'Admin', 'admin'],
        function(err) {
          if (err) {
            console.error('Erreur lors de la création:', err);
          } else {
            console.log('✅ Compte admin créé avec succès !');
            console.log('📧 Email:', adminEmail);
            console.log('🔑 Mot de passe:', adminPassword);
          }
          db.close();
        }
      );
    }
  });
});

