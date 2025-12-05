// Script pour tester la connexion MySQL
// Usage: node scripts/test-mysql-connection.js

require('dotenv').config({ path: process.env.NODE_ENV === 'production' ? '.env.production' : '.env' });
const db = require('../db');

(async () => {
  console.log('🔍 Test de connexion MySQL...');
  console.log('');
  console.log('Configuration:');
  console.log(`  DB_HOST: ${process.env.DB_HOST || 'localhost'}`);
  console.log(`  DB_USER: ${process.env.DB_USER || 'root'}`);
  console.log(`  DB_NAME: ${process.env.DB_NAME || 'auxivie'}`);
  console.log(`  DB_PORT: ${process.env.DB_PORT || 3306}`);
  console.log('');

  try {
    const connected = await db.testConnection();
    
    if (connected) {
      console.log('✅ Connexion MySQL réussie !');
      
      // Tester une requête simple
      try {
        const result = await db.query('SELECT 1 as test');
        console.log('✅ Requête SQL testée avec succès');
      } catch (error) {
        console.log('⚠️  Connexion OK mais erreur sur requête:', error.message);
      }
      
      process.exit(0);
    } else {
      console.log('❌ Échec de la connexion MySQL');
      console.log('');
      console.log('💡 Vérifiez :');
      console.log('   1. Les credentials dans .env');
      console.log('   2. Que MySQL est démarré : sudo systemctl status mysql');
      console.log('   3. Que l\'utilisateur existe et a les permissions');
      process.exit(1);
    }
  } catch (error) {
    console.error('❌ Erreur:', error.message);
    console.log('');
    console.log('💡 Solutions possibles :');
    console.log('   1. Vérifiez DB_USER et DB_PASSWORD dans .env');
    console.log('   2. Testez: mysql -u USER -p DATABASE');
    console.log('   3. Créez l\'utilisateur si nécessaire');
    process.exit(1);
  }
})();

