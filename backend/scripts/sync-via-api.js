const http = require('http');
const sqlite3 = require('sqlite3').verbose();
const path = require('path');

// Chemin de la base de données Flutter (à spécifier)
const flutterDbPath = process.argv[2];

if (!flutterDbPath) {
    console.error('❌ Veuillez spécifier le chemin de la base de données Flutter');
    console.log('Usage: node scripts/sync-via-api.js [CHEMIN_DB_FLUTTER]');
    process.exit(1);
}

const flutterDb = new sqlite3.Database(flutterDbPath, sqlite3.OPEN_READONLY, (err) => {
    if (err) {
        console.error('❌ Erreur ouverture DB Flutter:', err.message);
        process.exit(1);
    }
    console.log('📱 Base de données Flutter ouverte');
    syncUsers();
    syncReservations();
});

function syncUsers() {
    flutterDb.all('SELECT * FROM users', (err, users) => {
        if (err) {
            console.error('❌ Erreur lecture utilisateurs:', err);
            return;
        }

        console.log(`\n📊 ${users.length} utilisateur(s) à synchroniser\n`);

        users.forEach((user, index) => {
            setTimeout(() => {
                const postData = JSON.stringify({
                    name: user.name,
                    email: user.email,
                    password: user.password,
                    phone: user.phone,
                    categorie: user.categorie,
                    ville: user.ville,
                    tarif: user.tarif,
                    experience: user.experience,
                    photo: user.photo,
                    userType: user.userType,
                });

                const options = {
                    hostname: 'localhost',
                    port: 3001,
                    path: '/api/users/sync',
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'Content-Length': Buffer.byteLength(postData),
                    },
                };

                const req = http.request(options, (res) => {
                    let data = '';
                    res.on('data', (chunk) => {
                        data += chunk;
                    });
                    res.on('end', () => {
                        if (res.statusCode === 200 || res.statusCode === 201) {
                            console.log(`✅ ${user.email} synchronisé`);
                        } else {
                            console.log(`⚠️  ${user.email}: ${res.statusCode} - ${data}`);
                        }
                    });
                });

                req.on('error', (e) => {
                    console.error(`❌ Erreur pour ${user.email}: ${e.message}`);
                });

                req.write(postData);
                req.end();
            }, index * 200); // Délai de 200ms entre chaque requête
        });
    });
}

function syncReservations() {
    flutterDb.all('SELECT * FROM reservations', (err, reservations) => {
        if (err) {
            console.error('❌ Erreur lecture réservations:', err);
            return;
        }

        console.log(`\n📊 ${reservations.length} réservation(s) à synchroniser\n`);

        reservations.forEach((reservation, index) => {
            setTimeout(() => {
                // Convertir la date au format YYYY-MM-DD
                let dateStr = reservation.date;
                if (dateStr.includes('T')) {
                    dateStr = dateStr.split('T')[0];
                }

                const postData = JSON.stringify({
                    userId: reservation.userId,
                    professionnelId: reservation.professionnelId,
                    date: dateStr,
                    heure: reservation.heure,
                    status: reservation.status || 'pending',
                });

                const options = {
                    hostname: 'localhost',
                    port: 3001,
                    path: '/api/reservations/sync',
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'Content-Length': Buffer.byteLength(postData),
                    },
                };

                const req = http.request(options, (res) => {
                    let data = '';
                    res.on('data', (chunk) => {
                        data += chunk;
                    });
                    res.on('end', () => {
                        if (res.statusCode === 200 || res.statusCode === 201) {
                            console.log(`✅ Réservation ${reservation.id} synchronisée`);
                        } else {
                            console.log(`⚠️  Réservation ${reservation.id}: ${res.statusCode} - ${data}`);
                        }
                    });
                });

                req.on('error', (e) => {
                    console.error(`❌ Erreur réservation ${reservation.id}: ${e.message}`);
                });

                req.write(postData);
                req.end();
            }, index * 200);
        });
    });
}

