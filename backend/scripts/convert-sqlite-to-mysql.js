const fs = require('fs');
const path = require('path');

// Chemins des fichiers
const sqliteFile = path.join(__dirname, '..', 'data', 'auxivie.sql');
const mysqlFile = path.join(__dirname, '..', 'data', 'auxivie-mysql.sql');

console.log('🔄 Conversion SQLite → MySQL...');
console.log('📁 Fichier source:', sqliteFile);

// Lire le fichier SQLite
let sqlContent = fs.readFileSync(sqliteFile, 'utf8');

console.log('📊 Taille originale:', (sqlContent.length / 1024).toFixed(2), 'KB');

// Conversions
let mysqlContent = sqlContent;

// 1. Remplacer BEGIN TRANSACTION par START TRANSACTION
mysqlContent = mysqlContent.replace(/BEGIN TRANSACTION;/gi, 'START TRANSACTION;');

// 2. Convertir les guillemets doubles en backticks pour les noms de tables/colonnes
mysqlContent = mysqlContent.replace(/"(\w+)"/g, '`$1`');

// 3. Convertir AUTOINCREMENT en AUTO_INCREMENT
mysqlContent = mysqlContent.replace(/AUTOINCREMENT/gi, 'AUTO_INCREMENT');

// 4. Convertir PRIMARY KEY("id" AUTO_INCREMENT) en PRIMARY KEY (`id`)
mysqlContent = mysqlContent.replace(/PRIMARY KEY\s*\(`id`\s*AUTO_INCREMENT\)/gi, '`id` INT AUTO_INCREMENT PRIMARY KEY');

// 5. Convertir INTEGER en INT
mysqlContent = mysqlContent.replace(/\bINTEGER\b/gi, 'INT');

// 6. Convertir REAL en DECIMAL(10,2)
mysqlContent = mysqlContent.replace(/\bREAL\b/gi, 'DECIMAL(10,2)');

// 7. Convertir TEXT en VARCHAR(255) ou TEXT selon le contexte
// Pour les champs simples, utiliser VARCHAR(255)
// Pour les champs longs (content, description, etc.), garder TEXT
const longTextFields = ['content', 'description', 'comment', 'resolution', 'address', 'mission', 'besoin', 'preference', 'particularite'];
longTextFields.forEach(field => {
  mysqlContent = mysqlContent.replace(new RegExp(`\`${field}\`\\s+TEXT`, 'gi'), `\`${field}\` TEXT`);
});

// Pour les autres TEXT, utiliser VARCHAR(255)
mysqlContent = mysqlContent.replace(/\bTEXT\b(?!\s*(?:NOT\s+NULL|DEFAULT|UNIQUE|PRIMARY))/gi, 'VARCHAR(255)');

// 8. Corriger les CREATE TABLE pour ajouter ENGINE et CHARSET
mysqlContent = mysqlContent.replace(
  /(CREATE TABLE IF NOT EXISTS\s+`\w+`\s*\([^)]+\));/g,
  (match) => {
    if (!match.includes('ENGINE')) {
      return match.replace(/\);$/, ') ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;');
    }
    return match;
  }
);

// 9. Corriger les INSERT pour utiliser des backticks
mysqlContent = mysqlContent.replace(/INSERT INTO\s+"(\w+)"/gi, 'INSERT INTO `$1`');

// 10. Corriger les valeurs par défaut CURRENT_TIMESTAMP
mysqlContent = mysqlContent.replace(/DEFAULT CURRENT_TIMESTAMP/gi, "DEFAULT CURRENT_TIMESTAMP");

// 11. Corriger les valeurs par défaut avec des nombres
mysqlContent = mysqlContent.replace(/DEFAULT\s+(\d+)/gi, 'DEFAULT $1');

// 12. S'assurer que les valeurs NULL sont correctes dans les INSERT
// Les INSERT avec VALUES doivent avoir des valeurs correctement formatées

// 13. Ajouter SET NAMES utf8mb4 au début si pas présent
if (!mysqlContent.includes('SET NAMES')) {
  mysqlContent = 'SET NAMES utf8mb4;\nSET FOREIGN_KEY_CHECKS = 0;\n\n' + mysqlContent;
}

// 14. S'assurer que SET FOREIGN_KEY_CHECKS = 1 est à la fin
if (!mysqlContent.includes('SET FOREIGN_KEY_CHECKS = 1')) {
  mysqlContent = mysqlContent.trim() + '\n\nSET FOREIGN_KEY_CHECKS = 1;\n';
}

// 15. Corriger les FOREIGN KEY pour utiliser des backticks
mysqlContent = mysqlContent.replace(/FOREIGN KEY\s*\(`(\w+)`\)\s*REFERENCES\s+"(\w+)"\s*\(`(\w+)`\)/gi, 
  'FOREIGN KEY (`$1`) REFERENCES `$2` (`$3`)');

// 16. Corriger les UNIQUE constraints
mysqlContent = mysqlContent.replace(/UNIQUE\s*\(`(\w+)`\)/gi, 'UNIQUE KEY `$1` (`$1`)');

// Écrire le fichier MySQL
fs.writeFileSync(mysqlFile, mysqlContent, 'utf8');

console.log('✅ Conversion terminée!');
console.log('📁 Fichier MySQL:', mysqlFile);
console.log('📊 Taille finale:', (fs.statSync(mysqlFile).size / 1024).toFixed(2), 'KB');
console.log('\n💡 Vous pouvez maintenant importer auxivie-mysql.sql dans MySQL/phpMyAdmin');
console.log('⚠️  Note: Vérifiez le fichier avant l\'import pour s\'assurer que tout est correct');
