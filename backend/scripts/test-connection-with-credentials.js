// Script pour tester la connexion MySQL avec des credentials spécifiques
const mysql = require('mysql2/promise');

const dbConfig = {
  host: 'auth-db1232.hstgr.io',
  user: 'u133413376_root',
  password: 'Auxivie2025',
  database: 'u133413376_auxivie',
  port: 3306
};

(async () => {
  console.log('🔍 Test de connexion MySQL avec les credentials fournis...');
  console.log('');
  console.log('Configuration:');
  console.log(`  Host: ${dbConfig.host}`);
  console.log(`  User: ${dbConfig.user}`);
  console.log(`  Database: ${dbConfig.database}`);
  console.log(`  Port: ${dbConfig.port}`);
  console.log('');

  try {
    const connection = await mysql.createConnection(dbConfig);
    console.log('✅ Connexion MySQL réussie !');
    
    // Tester une requête simple
    const [rows] = await connection.execute('SELECT 1 as test');
    console.log('✅ Requête SQL testée avec succès');
    
    // Vérifier que la base existe et a des tables
    const [tables] = await connection.execute('SHOW TABLES');
    console.log(`✅ Base de données trouvée avec ${tables.length} table(s)`);
    
    if (tables.length > 0) {
      console.log('📋 Tables trouvées:');
      tables.forEach(table => {
        const tableName = Object.values(table)[0];
        console.log(`   - ${tableName}`);
      });
    }
    
    await connection.end();
    console.log('');
    console.log('✅ Tous les tests sont passés !');
    process.exit(0);
  } catch (error) {
    console.error('❌ Erreur de connexion:', error.message);
    console.log('');
    
    if (error.code === 'ER_ACCESS_DENIED_ERROR') {
      console.log('💡 Erreur d\'authentification. Vérifiez :');
      console.log('   1. Le nom d\'utilisateur est correct');
      console.log('   2. Le mot de passe est correct');
      console.log('   3. L\'utilisateur existe dans MySQL');
    } else if (error.code === 'ER_BAD_DB_ERROR') {
      console.log('💡 Base de données non trouvée. Vérifiez :');
      console.log('   1. Le nom de la base de données est correct');
      console.log('   2. La base de données existe');
      console.log('   3. L\'utilisateur a les permissions sur cette base');
    } else if (error.code === 'ECONNREFUSED') {
      console.log('💡 MySQL n\'est pas accessible. Vérifiez :');
      console.log('   1. MySQL est démarré : sudo systemctl status mysql');
      console.log('   2. MySQL écoute sur le port 3306');
    }
    
    process.exit(1);
  }
})();

