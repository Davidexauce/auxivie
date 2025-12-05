const path = require('path');
const fs = require('fs');

// Chemin de la base de données
const dbPath = path.join(__dirname, '..', 'data', 'auxivie.db');
const backupDir = path.join(__dirname, '..', 'backups');

// Créer le dossier backups s'il n'existe pas
if (!fs.existsSync(backupDir)) {
  fs.mkdirSync(backupDir, { recursive: true });
}

const timestamp = new Date().toISOString().replace(/[:.]/g, '-').split('T')[0];
const backupPath = path.join(backupDir, `auxivie-${timestamp}.db`);

console.log('💾 Création d\'une sauvegarde de la base de données...');
console.log('Source:', dbPath);
console.log('Destination:', backupPath);

// Vérifier que le fichier source existe
if (!fs.existsSync(dbPath)) {
  console.error('❌ Fichier source introuvable:', dbPath);
  process.exit(1);
}

try {
  // Copier le fichier
  fs.copyFileSync(dbPath, backupPath);
  
  const stats = fs.statSync(backupPath);
  console.log('✅ Sauvegarde créée avec succès');
  console.log(`📊 Taille: ${(stats.size / 1024).toFixed(2)} KB`);
  console.log(`📁 Fichier: ${backupPath}`);
} catch (error) {
  console.error('❌ Erreur sauvegarde:', error.message);
  process.exit(1);
}

