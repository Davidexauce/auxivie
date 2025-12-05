// Script pour créer ou mettre à jour l'utilisateur admin dans MySQL
require('dotenv').config({ path: process.env.NODE_ENV === 'production' ? '.env.production' : '.env' });
const db = require('../db');
const bcrypt = require('bcryptjs');

const adminEmail = 'admin@auxivie.com';
const adminPassword = 'admin123'; // Mot de passe par défaut

async function createOrUpdateAdmin() {
  try {
    console.log('🔍 Vérification de l\'utilisateur admin...');
    console.log('📧 Email:', adminEmail);
    
    // Vérifier si l'admin existe déjà
    const existingAdmin = await db.get(
      'SELECT id, email, password FROM users WHERE email = ?',
      [adminEmail]
    );

    if (existingAdmin) {
      console.log('✅ Admin trouvé, mise à jour du mot de passe...');
      
      // Hasher le nouveau mot de passe
      const hash = await bcrypt.hash(adminPassword, 10);
      
      // Mettre à jour le mot de passe
      await db.run(
        'UPDATE users SET password = ?, userType = ?, categorie = ? WHERE email = ?',
        [hash, 'admin', 'Admin', adminEmail]
      );
      
      console.log('✅ Mot de passe admin mis à jour avec succès !');
      console.log('📧 Email:', adminEmail);
      console.log('🔑 Mot de passe:', adminPassword);
    } else {
      console.log('📝 Création du compte admin...');
      
      // Hasher le mot de passe
      const hash = await bcrypt.hash(adminPassword, 10);
      
      // Créer l'admin
      const result = await db.run(
        `INSERT INTO users (name, email, password, categorie, userType, createdAt, updatedAt) 
         VALUES (?, ?, ?, ?, ?, NOW(), NOW())`,
        ['Administrateur', adminEmail, hash, 'Admin', 'admin']
      );
      
      console.log('✅ Compte admin créé avec succès !');
      console.log('📧 Email:', adminEmail);
      console.log('🔑 Mot de passe:', adminPassword);
      console.log('🆔 ID:', result.lastID);
    }
    
    // Vérifier que l'admin peut se connecter
    console.log('\n🧪 Test de connexion...');
    const admin = await db.get(
      'SELECT id, email, userType, categorie FROM users WHERE email = ?',
      [adminEmail]
    );
    
    if (admin) {
      console.log('✅ Admin vérifié dans la base de données:');
      console.log('   ID:', admin.id);
      console.log('   Email:', admin.email);
      console.log('   Type:', admin.userType);
      console.log('   Catégorie:', admin.categorie);
    }
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Erreur:', error.message);
    console.error('Stack:', error.stack);
    process.exit(1);
  }
}

// Exécuter
createOrUpdateAdmin();

