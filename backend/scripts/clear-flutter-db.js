const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const fs = require('fs');

// Chemin de la base de données Flutter (à spécifier en argument)
const flutterDbPath = process.argv[2];

if (!flutterDbPath) {
    console.error('❌ Veuillez spécifier le chemin de la base de données Flutter');
    console.log('Usage: node scripts/clear-flutter-db.js [CHEMIN_DB_FLUTTER]');
    console.log('\n💡 Pour trouver le chemin:');
    console.log('   find ~/Library/Developer/CoreSimulator/Devices -name "auxivie.db"');
    process.exit(1);
}

if (!fs.existsSync(flutterDbPath)) {
    console.error(`❌ Base de données introuvable: ${flutterDbPath}`);
    process.exit(1);
}

const flutterDb = new sqlite3.Database(flutterDbPath, (err) => {
    if (err) {
        console.error('❌ Erreur ouverture DB:', err.message);
        process.exit(1);
    }
    console.log(`📱 Base de données Flutter ouverte: ${flutterDbPath}\n`);
    clearAllData();
});

function clearAllData() {
    console.log('🗑️  Suppression de toutes les données Flutter...\n');

    // Supprimer les réservations
    flutterDb.run('DELETE FROM reservations', (err) => {
        if (err) {
            console.error('❌ Erreur suppression réservations:', err);
        } else {
            console.log('✅ Réservations supprimées');
        }
    });

    // Supprimer les messages
    flutterDb.run('DELETE FROM messages', (err) => {
        if (err) {
            console.error('❌ Erreur suppression messages:', err);
        } else {
            console.log('✅ Messages supprimés');
        }
    });

    // Supprimer les documents
    flutterDb.run('DELETE FROM documents', (err) => {
        if (err) {
            console.error('❌ Erreur suppression documents:', err);
        } else {
            console.log('✅ Documents supprimés');
        }
    });

    // Supprimer les badges
    flutterDb.run('DELETE FROM user_badges', (err) => {
        if (err && !err.message.includes('no such table')) {
            console.error('❌ Erreur suppression badges:', err);
        } else {
            console.log('✅ Badges supprimés');
        }
    });

    // Supprimer les notes
    flutterDb.run('DELETE FROM user_ratings', (err) => {
        if (err && !err.message.includes('no such table')) {
            console.error('❌ Erreur suppression notes:', err);
        } else {
            console.log('✅ Notes supprimées');
        }
    });

    // Supprimer les avis
    flutterDb.run('DELETE FROM reviews', (err) => {
        if (err && !err.message.includes('no such table')) {
            console.error('❌ Erreur suppression avis:', err);
        } else {
            console.log('✅ Avis supprimés');
        }
    });

    // Supprimer tous les utilisateurs
    flutterDb.run('DELETE FROM users', (err) => {
        if (err) {
            console.error('❌ Erreur suppression utilisateurs:', err);
        } else {
            console.log('✅ Utilisateurs supprimés');
        }

        console.log('\n✅ Nettoyage Flutter terminé !\n');
        flutterDb.close();
    });
}

