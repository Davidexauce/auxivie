const sqlite3 = require('sqlite3').verbose();
const fs = require('fs');
const path = require('path');
require('dotenv').config();

const dbPath = process.env.DB_PATH || path.join(__dirname, '../data/auxivie.db');
const backupDir = path.join(__dirname, '../backups');

// Créer le répertoire de backup s'il n'existe pas
if (!fs.existsSync(backupDir)) {
  fs.mkdirSync(backupDir, { recursive: true });
}

const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
const backupPath = path.join(backupDir, `auxivie-backup-${timestamp}.db`);

console.log('💾 Création d\'un backup de la base de données...');
console.log(`📁 Source: ${dbPath}`);
console.log(`📁 Destination: ${backupPath}`);

const db = new sqlite3.Database(dbPath, (err) => {
  if (err) {
    console.error('❌ Erreur connexion base de données:', err);
    process.exit(1);
  }
});

// Créer le backup
db.backup(backupPath)
  .then(() => {
    console.log('✅ Backup créé avec succès!');
    
    // Nettoyer les anciens backups (garder les 10 derniers)
    const backups = fs.readdirSync(backupDir)
      .filter(f => f.startsWith('auxivie-backup-') && f.endsWith('.db'))
      .map(f => ({
        name: f,
        path: path.join(backupDir, f),
        time: fs.statSync(path.join(backupDir, f)).mtime
      }))
      .sort((a, b) => b.time - a.time);
    
    if (backups.length > 10) {
      console.log(`🧹 Nettoyage des anciens backups (garder les 10 derniers)...`);
      backups.slice(10).forEach(backup => {
        fs.unlinkSync(backup.path);
        console.log(`🗑️  Supprimé: ${backup.name}`);
      });
    }
    
    db.close();
    process.exit(0);
  })
  .catch((err) => {
    console.error('❌ Erreur lors du backup:', err);
    db.close();
    process.exit(1);
  });

