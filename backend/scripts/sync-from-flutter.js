const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const fs = require('fs');
const os = require('os');

// Chemins des bases de données
const flutterDbPath = path.join(
  os.homedir(),
  'Library',
  'Developer',
  'CoreSimulator',
  'Devices',
  // On va chercher dans le répertoire de l'app Flutter
  // Pour iOS Simulator, le chemin est généralement dans ~/Library/Developer/CoreSimulator/Devices/[DEVICE_ID]/data/Containers/Data/Application/[APP_ID]/Documents/
);

// Alternative: chercher dans le répertoire de l'app Flutter directement
const projectRoot = path.join(__dirname, '..', '..');
const flutterDbAlternative = path.join(projectRoot, 'data', 'auxivie.db');

// Base de données backend
const backendDbPath = path.join(__dirname, '..', 'data', 'auxivie.db');

console.log('🔄 Synchronisation des données Flutter → Backend\n');

// Fonction pour trouver la base de données Flutter
function findFlutterDatabase() {
  // Essayer plusieurs emplacements possibles
  const possiblePaths = [
    // Emplacement dans le projet (si copié)
    flutterDbAlternative,
    // Emplacement iOS Simulator (nécessite de trouver le device)
    path.join(os.homedir(), 'Library', 'Developer', 'CoreSimulator', 'Devices'),
    // Emplacement Android (si disponible)
    path.join(os.homedir(), 'Android', 'data'),
  ];

  // Pour l'instant, on va utiliser un chemin relatif au projet
  // L'utilisateur devra peut-être spécifier le chemin manuellement
  return flutterDbAlternative;
}

// Fonction principale de synchronisation
async function syncUsers(customPath = null) {
  return new Promise((resolve, reject) => {
    const flutterDbPath = customPath || findFlutterDatabase();
    
    // Vérifier si la base de données Flutter existe
    if (!fs.existsSync(flutterDbPath)) {
      console.log('❌ Base de données Flutter introuvable à:', flutterDbPath);
      console.log('💡 Astuce: Copiez votre base de données Flutter vers:');
      console.log('   ', flutterDbAlternative);
      console.log('\n   Ou spécifiez le chemin complet avec:');
      console.log('   node scripts/sync-from-flutter.js [CHEMIN_COMPLET]');
      reject(new Error('Base de données Flutter introuvable'));
      return;
    }

    console.log('📱 Base de données Flutter:', flutterDbPath);
    console.log('🖥️  Base de données Backend:', backendDbPath);
    console.log('');

    const flutterDb = new sqlite3.Database(flutterDbPath, sqlite3.OPEN_READONLY, (err) => {
      if (err) {
        console.error('❌ Erreur ouverture DB Flutter:', err.message);
        reject(err);
        return;
      }
    });

    const backendDb = new sqlite3.Database(backendDbPath, (err) => {
      if (err) {
        console.error('❌ Erreur ouverture DB Backend:', err.message);
        flutterDb.close();
        reject(err);
        return;
      }

      // Lire tous les utilisateurs de Flutter
      flutterDb.all('SELECT * FROM users', [], (err, flutterUsers) => {
        if (err) {
          console.error('❌ Erreur lecture Flutter:', err.message);
          flutterDb.close();
          backendDb.close();
          reject(err);
          return;
        }

        console.log(`📊 ${flutterUsers.length} utilisateur(s) trouvé(s) dans Flutter\n`);

        if (flutterUsers.length === 0) {
          console.log('✅ Aucun utilisateur à synchroniser');
          flutterDb.close();
          backendDb.close();
          resolve();
          return;
        }

        let synced = 0;
        let skipped = 0;
        let errors = 0;

        // Synchroniser chaque utilisateur
        flutterUsers.forEach((flutterUser, index) => {
          // Vérifier si l'utilisateur existe déjà dans le backend
          backendDb.get(
            'SELECT id FROM users WHERE email = ?',
            [flutterUser.email],
            (err, existingUser) => {
              if (err) {
                console.error(`❌ Erreur vérification ${flutterUser.email}:`, err.message);
                errors++;
                checkComplete();
                return;
              }

              if (existingUser) {
                console.log(`⏭️  ${flutterUser.email} existe déjà (ignoré)`);
                skipped++;
                checkComplete();
                return;
              }

              // Insérer l'utilisateur dans le backend
              backendDb.run(
                `INSERT INTO users (name, email, password, phone, categorie, ville, tarif, experience, photo, userType)
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
                [
                  flutterUser.name,
                  flutterUser.email,
                  flutterUser.password, // Le mot de passe est déjà hashé
                  flutterUser.phone || null,
                  flutterUser.categorie,
                  flutterUser.ville || null,
                  flutterUser.tarif || null,
                  flutterUser.experience || null,
                  flutterUser.photo || null,
                  flutterUser.userType,
                ],
                function(insertErr) {
                  if (insertErr) {
                    console.error(`❌ Erreur insertion ${flutterUser.email}:`, insertErr.message);
                    errors++;
                  } else {
                    console.log(`✅ ${flutterUser.email} synchronisé (ID: ${this.lastID})`);
                    synced++;
                  }
                  checkComplete();
                }
              );
            }
          );
        });

        function checkComplete() {
          if (synced + skipped + errors === flutterUsers.length) {
            console.log('\n📈 Résumé de la synchronisation:');
            console.log(`   ✅ Synchronisés: ${synced}`);
            console.log(`   ⏭️  Ignorés: ${skipped}`);
            console.log(`   ❌ Erreurs: ${errors}`);
            console.log('\n✅ Synchronisation terminée!\n');
            
            flutterDb.close();
            backendDb.close();
            resolve();
          }
        }
      });
    });
  });
}

// Exécuter la synchronisation
if (require.main === module) {
  const customPath = process.argv[2];
  const flutterDbPath = customPath ? path.resolve(customPath) : null;

  if (customPath && !fs.existsSync(flutterDbPath)) {
    console.error('❌ Chemin invalide:', flutterDbPath);
    process.exit(1);
  }

  syncUsers(flutterDbPath)
    .then(() => {
      process.exit(0);
    })
    .catch((err) => {
      console.error('❌ Erreur:', err.message);
      process.exit(1);
    });
}

module.exports = { syncUsers };

