// Script pour convertir les requêtes SQLite en MySQL dans server.js
// Ce script remplace les patterns courants

const fs = require('fs');
const path = require('path');

const serverFile = path.join(__dirname, '..', 'server.js');
let content = fs.readFileSync(serverFile, 'utf8');

// Remplacer datetime("now") par NOW()
content = content.replace(/datetime\("now"\)/g, 'NOW()');

// Remplacer INSERT OR REPLACE par INSERT ... ON DUPLICATE KEY UPDATE
content = content.replace(/INSERT OR REPLACE INTO/g, 'INSERT INTO');

// Sauvegarder
fs.writeFileSync(serverFile, content, 'utf8');
console.log('✅ Conversions SQL effectuées');

