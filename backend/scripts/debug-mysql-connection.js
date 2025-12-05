// Script de diagnostic approfondi pour la connexion MySQL
require('dotenv').config();

console.log('🔍 Diagnostic approfondi de la connexion MySQL...');
console.log('');

// Afficher les variables d'environnement
console.log('📋 Variables d\'environnement lues:');
console.log('  DB_HOST:', process.env.DB_HOST);
console.log('  DB_USER:', process.env.DB_USER);
console.log('  DB_PASSWORD:', process.env.DB_PASSWORD ? `"${process.env.DB_PASSWORD}" (${process.env.DB_PASSWORD.length} caractères)` : 'MANQUANT');
console.log('  DB_NAME:', process.env.DB_NAME);
console.log('  DB_PORT:', process.env.DB_PORT);
console.log('');

// Vérifier les types
console.log('📊 Types des variables:');
console.log('  DB_HOST type:', typeof process.env.DB_HOST);
console.log('  DB_USER type:', typeof process.env.DB_USER);
console.log('  DB_PASSWORD type:', typeof process.env.DB_PASSWORD);
console.log('  DB_NAME type:', typeof process.env.DB_NAME);
console.log('');

// Vérifier les espaces
if (process.env.DB_USER) {
  console.log('🔍 Analyse DB_USER:');
  console.log('  Longueur:', process.env.DB_USER.length);
  console.log('  Commence par espace:', process.env.DB_USER.startsWith(' '));
  console.log('  Se termine par espace:', process.env.DB_USER.endsWith(' '));
  console.log('  Valeur exacte (hex):', Buffer.from(process.env.DB_USER).toString('hex'));
  console.log('');
}

if (process.env.DB_PASSWORD) {
  console.log('🔍 Analyse DB_PASSWORD:');
  console.log('  Longueur:', process.env.DB_PASSWORD.length);
  console.log('  Commence par espace:', process.env.DB_PASSWORD.startsWith(' '));
  console.log('  Se termine par espace:', process.env.DB_PASSWORD.endsWith(' '));
  console.log('  Valeur exacte (hex):', Buffer.from(process.env.DB_PASSWORD).toString('hex'));
  console.log('');
}

// Tester avec les valeurs exactes
const mysql = require('mysql2/promise');

const config1 = {
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  port: parseInt(process.env.DB_PORT) || 3306
};

const config2 = {
  host: 'auth-db1232.hstgr.io',
  user: 'u133413376_root',
  password: 'Auxivie2025',
  database: 'u133413376_auxivie',
  port: 3306
};

console.log('🧪 Test 1: Avec les variables d\'environnement...');
(async () => {
  try {
    const conn1 = await mysql.createConnection(config1);
    console.log('✅ Connexion réussie avec variables d\'environnement !');
    await conn1.end();
  } catch (error) {
    console.error('❌ Erreur avec variables d\'environnement:', error.message);
    console.error('   Code:', error.code);
  }

  console.log('');
  console.log('🧪 Test 2: Avec valeurs codées en dur...');
  try {
    const conn2 = await mysql.createConnection(config2);
    console.log('✅ Connexion réussie avec valeurs codées !');
    await conn2.end();
  } catch (error) {
    console.error('❌ Erreur avec valeurs codées:', error.message);
    console.error('   Code:', error.code);
  }

  console.log('');
  console.log('🧪 Test 3: Comparaison des valeurs...');
  console.log('  DB_USER === "u133413376_root":', process.env.DB_USER === 'u133413376_root');
  console.log('  DB_PASSWORD === "Auxivie2025":', process.env.DB_PASSWORD === 'Auxivie2025');
  console.log('  DB_NAME === "u133413376_auxivie":', process.env.DB_NAME === 'u133413376_auxivie');
  
  if (process.env.DB_USER !== 'u133413376_root') {
    console.log('');
    console.log('⚠️  DB_USER ne correspond pas exactement !');
    console.log('   Attendu: "u133413376_root"');
    console.log('   Reçu: "' + process.env.DB_USER + '"');
    console.log('   Différence de caractères:', process.env.DB_USER.length - 'u133413376_root'.length);
  }
  
  if (process.env.DB_PASSWORD !== 'Auxivie2025') {
    console.log('');
    console.log('⚠️  DB_PASSWORD ne correspond pas exactement !');
    console.log('   Attendu: "Auxivie2025"');
    console.log('   Reçu: "' + process.env.DB_PASSWORD + '"');
    console.log('   Différence de caractères:', process.env.DB_PASSWORD.length - 'Auxivie2025'.length);
  }
})();

