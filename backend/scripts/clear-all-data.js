const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const fs = require('fs');

// Chemin de la base de données backend
const backendDbPath = path.join(__dirname, '../data', 'auxivie.db');
const backendDb = new sqlite3.Database(backendDbPath);

console.log('🗑️  Suppression de toutes les données...\n');
console.log(`📁 Base de données backend: ${backendDbPath}\n`);

// Fonction pour supprimer toutes les données sauf l'admin
function clearAllData() {
  console.log('🔄 Suppression en cours...\n');

  // Supprimer les réservations
  backendDb.run('DELETE FROM reservations', (err) => {
    if (err) {
      console.error('❌ Erreur suppression réservations:', err);
    } else {
      console.log('✅ Réservations supprimées');
    }
  });

  // Supprimer les messages
  backendDb.run('DELETE FROM messages', (err) => {
    if (err) {
      console.error('❌ Erreur suppression messages:', err);
    } else {
      console.log('✅ Messages supprimés');
    }
  });

  // Supprimer les documents
  backendDb.run('DELETE FROM documents', (err) => {
    if (err) {
      console.error('❌ Erreur suppression documents:', err);
    } else {
      console.log('✅ Documents supprimés');
    }
  });

  // Supprimer les paiements
  backendDb.run('DELETE FROM payments', (err) => {
    if (err) {
      console.error('❌ Erreur suppression paiements:', err);
    } else {
      console.log('✅ Paiements supprimés');
    }
  });

  // Supprimer les badges
  backendDb.run('DELETE FROM user_badges', (err) => {
    if (err) {
      console.error('❌ Erreur suppression badges:', err);
    } else {
      console.log('✅ Badges supprimés');
    }
  });

  // Supprimer les notes
  backendDb.run('DELETE FROM user_ratings', (err) => {
    if (err) {
      console.error('❌ Erreur suppression notes:', err);
    } else {
      console.log('✅ Notes supprimées');
    }
  });

  // Supprimer les avis
  backendDb.run('DELETE FROM reviews', (err) => {
    if (err) {
      console.error('❌ Erreur suppression avis:', err);
    } else {
      console.log('✅ Avis supprimés');
    }
  });

  // Supprimer tous les utilisateurs sauf l'admin
  backendDb.run("DELETE FROM users WHERE userType != 'admin'", (err) => {
    if (err) {
      console.error('❌ Erreur suppression utilisateurs:', err);
    } else {
      console.log('✅ Utilisateurs supprimés (admin conservé)');
    }

    // Vérifier que l'admin existe toujours
    backendDb.get("SELECT id, email FROM users WHERE userType = 'admin'", (err, admin) => {
      if (err) {
        console.error('❌ Erreur vérification admin:', err);
      } else if (admin) {
        console.log(`✅ Admin conservé: ${admin.email} (ID: ${admin.id})`);
      } else {
        console.log('⚠️  Aucun admin trouvé - vous devrez en créer un avec create-admin.js');
      }

      console.log('\n✅ Nettoyage terminé !\n');
      backendDb.close();
    });
  });
}

// Confirmation
console.log('⚠️  ATTENTION: Cette opération va supprimer TOUTES les données !');
console.log('   - Tous les utilisateurs (sauf admin)');
console.log('   - Toutes les réservations');
console.log('   - Tous les messages');
console.log('   - Tous les documents');
console.log('   - Tous les paiements');
console.log('   - Tous les badges');
console.log('   - Toutes les notes');
console.log('   - Tous les avis\n');

// Exécuter le nettoyage
clearAllData();

