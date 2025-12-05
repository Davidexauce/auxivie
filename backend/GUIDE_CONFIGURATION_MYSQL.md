# 🔧 Guide de Configuration MySQL

## Variables d'Environnement Requises

Créez un fichier `.env` dans le dossier `backend/` avec :

```env
# Port du serveur
PORT=3001

# Environnement
NODE_ENV=production

# Configuration MySQL
DB_HOST=auth-db1232.hstgr.io
DB_USER=u133413376_root
DB_PASSWORD=Auxivie2025
DB_NAME=u133413376_auxivie
DB_PORT=3306

# JWT Secret (changez cette valeur par une clé secrète aléatoire)
JWT_SECRET=votre_cle_secrete_tres_longue_et_aleatoire_ici

# CORS - Autoriser les requêtes depuis le dashboard
CORS_ORIGIN=https://www.auxivie.org

# Stripe (si vous utilisez les paiements)
STRIPE_SECRET_KEY=sk_test_votre_cle_stripe
STRIPE_PUBLISHABLE_KEY=pk_test_votre_cle_stripe

# Uploads
UPLOADS_DIR=./uploads
```

## 🔑 Où Trouver les Credentials MySQL sur Hostinger

1. **Connectez-vous à Hostinger hPanel**
2. Allez dans **"Databases"** → **"MySQL Databases"**
3. Vous verrez :
   - **Database Name** : `u133413376_auxivie` (ou similaire)
   - **Database User** : `u133413376_username` (ou similaire)
   - **Database Password** : (celui que vous avez défini)
   - **Host** : `localhost` (généralement)

## 📝 Exemple de Configuration

```env
DB_HOST=auth-db1232.hstgr.io
DB_USER=u133413376_root
DB_PASSWORD=Auxivie2025
DB_NAME=u133413376_auxivie
DB_PORT=3306
```

## ✅ Vérification

Pour tester la connexion, vous pouvez créer un script de test :

```javascript
const db = require('./db');

(async () => {
  const connected = await db.testConnection();
  if (connected) {
    console.log('✅ Connexion MySQL réussie');
    process.exit(0);
  } else {
    console.log('❌ Échec de la connexion MySQL');
    process.exit(1);
  }
})();
```

Exécutez : `node test-db.js`

## 🔒 Sécurité

- ⚠️ **NE COMMITEZ JAMAIS** le fichier `.env` sur GitHub
- Le fichier `.env` est déjà dans `.gitignore`
- Utilisez des mots de passe forts
- Changez `JWT_SECRET` par une clé aléatoire

## 🚀 Déploiement

1. Créez le fichier `.env` sur Hostinger
2. Ajoutez les credentials MySQL
3. Redémarrez l'application Node.js
4. Vérifiez les logs pour confirmer la connexion

