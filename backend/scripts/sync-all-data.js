const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const fs = require('fs');
const bcrypt = require('bcryptjs');
const http = require('http');

// Chemin de la base de données backend
const backendDbPath = path.join(__dirname, '../data', 'auxivie.db');
const backendDb = new sqlite3.Database(backendDbPath);

// Fonction pour trouver le chemin de la DB Flutter
function findFlutterDbPath() {
    const homeDir = process.env.HOME || process.env.USERPROFILE;
    const simulatorPaths = [
        // iOS Simulator paths
        `${homeDir}/Library/Developer/CoreSimulator/Devices/*/data/Containers/Data/Application/*/Documents/auxivie.db`,
    ];

    for (const pattern of simulatorPaths) {
        try {
            const glob = require('glob');
            const files = glob.sync(pattern);
            if (files.length > 0) {
                return files[0];
            }
        } catch (e) {
            // glob not available, try alternative
        }
    }
    return null;
}

// Déterminer le chemin de la DB Flutter
let flutterDbPath = process.argv[2];
if (!flutterDbPath) {
    flutterDbPath = findFlutterDbPath();
}

if (!flutterDbPath || !fs.existsSync(flutterDbPath)) {
    console.error(`❌ Base de données Flutter introuvable à: ${flutterDbPath || 'chemin non spécifié'}`);
    console.log(`💡 Spécifiez le chemin complet avec:`);
    console.log(`   node scripts/sync-all-data.js [CHEMIN_COMPLET]`);
    process.exit(1);
}

const flutterDb = new sqlite3.Database(flutterDbPath, sqlite3.OPEN_READONLY, (err) => {
    if (err) {
        console.error('❌ Erreur lors de l\'ouverture de la base de données Flutter:', err.message);
        process.exit(1);
    }
    console.log(`📱 Base de données Flutter trouvée: ${flutterDbPath}`);
    console.log('🔄 Synchronisation complète des données Flutter → Backend\n');
    syncAllData();
});

async function syncAllData() {
    let usersSynced = 0;
    let reservationsSynced = 0;
    let errors = 0;

    console.log(`📱 Base de données Flutter: ${flutterDbPath}`);
    console.log(`🖥️  Base de données Backend: ${backendDbPath}\n`);

    // Synchroniser les utilisateurs
    flutterDb.all('SELECT * FROM users', async (err, flutterUsers) => {
        if (err) {
            console.error('❌ Erreur lors de la lecture des utilisateurs Flutter:', err.message);
            errors++;
        } else {
            console.log(`📊 ${flutterUsers.length} utilisateur(s) trouvé(s) dans Flutter`);

            for (const user of flutterUsers) {
                // Vérifier si l'utilisateur existe déjà dans le backend
                backendDb.get('SELECT id FROM users WHERE email = ?', [user.email], async (err, row) => {
                    if (err) {
                        console.error(`❌ Erreur lors de la vérification de l'utilisateur ${user.email}:`, err.message);
                        errors++;
                        return;
                    }

                    if (row) {
                        console.log(`⏭️  Utilisateur ${user.email} existe déjà, ignoré.`);
                    } else {
                        // Hasher le mot de passe avant d'insérer
                        const hashedPassword = await bcrypt.hash(user.password, 10);

                        backendDb.run(
                            `INSERT INTO users (name, email, password, phone, categorie, ville, tarif, experience, photo, userType, createdAt)
                             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, datetime('now'))`,
                            [
                                user.name,
                                user.email,
                                hashedPassword,
                                user.phone,
                                user.categorie,
                                user.ville,
                                user.tarif,
                                user.experience,
                                user.photo,
                                user.userType,
                            ],
                            function(err) {
                                if (err) {
                                    console.error(`❌ Erreur lors de l'insertion de l'utilisateur ${user.email}:`, err.message);
                                    errors++;
                                } else {
                                    console.log(`✅ ${user.email} synchronisé (ID: ${this.lastID})`);
                                    usersSynced++;
                                }
                            }
                        );
                    }
                });
            }
        }

        // Synchroniser les réservations
        flutterDb.all('SELECT * FROM reservations', async (err, flutterReservations) => {
            if (err) {
                console.error('❌ Erreur lors de la lecture des réservations Flutter:', err.message);
                errors++;
            } else {
                console.log(`\n📊 ${flutterReservations.length} réservation(s) trouvée(s) dans Flutter`);

                for (const reservation of flutterReservations) {
                    // Vérifier si la réservation existe déjà
                    backendDb.get(
                        'SELECT id FROM reservations WHERE userId = ? AND professionnelId = ? AND date = ? AND heure = ?',
                        [reservation.userId, reservation.professionnelId, reservation.date, reservation.heure],
                        (err, row) => {
                            if (err) {
                                console.error(`❌ Erreur lors de la vérification de la réservation:`, err.message);
                                errors++;
                                return;
                            }

                            if (row) {
                                console.log(`⏭️  Réservation existe déjà, ignorée.`);
                            } else {
                                backendDb.run(
                                    `INSERT INTO reservations (userId, professionnelId, date, heure, status, createdAt)
                                     VALUES (?, ?, ?, ?, ?, datetime('now'))`,
                                    [
                                        reservation.userId,
                                        reservation.professionnelId,
                                        reservation.date,
                                        reservation.heure,
                                        reservation.status || 'pending',
                                    ],
                                    function(err) {
                                        if (err) {
                                            console.error(`❌ Erreur lors de l'insertion de la réservation:`, err.message);
                                            errors++;
                                        } else {
                                            console.log(`✅ Réservation synchronisée (ID: ${this.lastID})`);
                                            reservationsSynced++;
                                        }
                                    }
                                );
                            }
                        }
                    );
                }
            }

            // Attendre un peu pour que toutes les opérations se terminent
            setTimeout(() => {
                console.log('\n📈 Résumé de la synchronisation:');
                console.log(`   ✅ Utilisateurs synchronisés: ${usersSynced}`);
                console.log(`   ✅ Réservations synchronisées: ${reservationsSynced}`);
                console.log(`   ❌ Erreurs: ${errors}`);
                console.log('\n✅ Synchronisation terminée!\n');
                flutterDb.close();
                backendDb.close();
            }, 2000);
        });
    });
}

