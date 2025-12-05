// Script pour tester la connexion admin
require('dotenv').config({ path: process.env.NODE_ENV === 'production' ? '.env.production' : '.env' });
const db = require('../db');
const bcrypt = require('bcryptjs');

const adminEmail = 'admin@auxivie.com';
const adminPassword = 'admin123';

async function testAdmin() {
  try {
    console.log('🔍 Vérification de l\'admin...');
    console.log('📧 Email:', adminEmail);
    console.log('');
    
    // Vérifier si l'admin existe
    const admin = await db.get(
      'SELECT id, email, password, userType, categorie, name FROM users WHERE email = ?',
      [adminEmail]
    );
    
    if (!admin) {
      console.log('❌ Admin non trouvé dans la base de données !');
      console.log('');
      console.log('💡 Solution: Exécutez le script create-admin-mysql.js');
      console.log('   node scripts/create-admin-mysql.js');
      process.exit(1);
    }
    
    console.log('✅ Admin trouvé:');
    console.log('   ID:', admin.id);
    console.log('   Nom:', admin.name);
    console.log('   Email:', admin.email);
    console.log('   Type:', admin.userType);
    console.log('   Catégorie:', admin.categorie);
    console.log('   Mot de passe hashé:', admin.password ? 'Oui' : 'Non');
    console.log('');
    
    // Vérifier le type d'utilisateur
    if (admin.userType !== 'admin') {
      console.log('⚠️  ATTENTION: userType n\'est pas "admin" !');
      console.log('   Type actuel:', admin.userType);
      console.log('');
      console.log('💡 Solution: Mettez à jour userType à "admin"');
      console.log('   UPDATE users SET userType = "admin" WHERE email = "admin@auxivie.com";');
      process.exit(1);
    }
    
    // Tester le mot de passe
    console.log('🧪 Test du mot de passe...');
    let passwordValid = false;
    
    if (admin.password && admin.password.startsWith('$2b$')) {
      // Mot de passe hashé avec bcrypt
      passwordValid = await bcrypt.compare(adminPassword, admin.password);
      console.log('   Format: bcrypt hashé');
    } else if (admin.password) {
      // Mot de passe en clair
      passwordValid = admin.password === adminPassword;
      console.log('   Format: texte en clair (⚠️  doit être hashé)');
    } else {
      console.log('   ❌ Pas de mot de passe défini');
    }
    
    if (passwordValid) {
      console.log('   ✅ Mot de passe correct !');
    } else {
      console.log('   ❌ Mot de passe incorrect !');
      console.log('');
      console.log('💡 Solution: Réinitialisez le mot de passe avec create-admin-mysql.js');
      process.exit(1);
    }
    
    console.log('');
    console.log('✅ Tous les tests sont passés !');
    console.log('   L\'admin devrait pouvoir se connecter au Dashboard.');
    console.log('');
    console.log('🧪 Test de connexion API...');
    
    // Tester la connexion via l'API
    const http = require('http');
    const postData = JSON.stringify({
      email: adminEmail,
      password: adminPassword
    });
    
    const options = {
      hostname: 'localhost',
      port: 3001,
      path: '/api/auth/login',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(postData)
      }
    };
    
    const req = http.request(options, (res) => {
      let data = '';
      
      res.on('data', (chunk) => {
        data += chunk;
      });
      
      res.on('end', () => {
        if (res.statusCode === 200) {
          const response = JSON.parse(data);
          console.log('   ✅ Connexion API réussie !');
          console.log('   Token reçu:', response.token ? 'Oui' : 'Non');
          console.log('   User:', response.user ? response.user.email : 'Non');
        } else {
          console.log('   ❌ Erreur de connexion API:', res.statusCode);
          console.log('   Réponse:', data);
        }
        process.exit(res.statusCode === 200 ? 0 : 1);
      });
    });
    
    req.on('error', (error) => {
      console.log('   ❌ Erreur de connexion:', error.message);
      console.log('   💡 Assurez-vous que le serveur est démarré (npm start)');
      process.exit(1);
    });
    
    req.write(postData);
    req.end();
    
  } catch (error) {
    console.error('❌ Erreur:', error.message);
    console.error('Stack:', error.stack);
    process.exit(1);
  }
}

testAdmin();

