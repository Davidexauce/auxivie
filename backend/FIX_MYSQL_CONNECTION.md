# 🔧 Résolution Erreur Connexion MySQL

## ❌ Erreur Actuelle

```
Access denied for user 'root'@'localhost' (using password: YES)
```

Cela signifie que les credentials MySQL dans `.env` sont incorrects.

---

## 🔍 Étape 1 : Vérifier les Credentials MySQL

### Sur le VPS

```bash
cd ~/backend/backend
cat .env
```

Vérifiez les valeurs de :
- `DB_USER`
- `DB_PASSWORD`
- `DB_NAME`
- `DB_HOST`

---

## 🔑 Étape 2 : Obtenir les Vrais Credentials MySQL

### Option A : Via Hostinger hPanel

1. Connectez-vous à **Hostinger hPanel**
2. Allez dans **"Databases"** → **"MySQL Databases"**
3. Vous verrez :
   - **Database Name** : `u133413376_auxivie` (ou similaire)
   - **Database User** : `u133413376_username` (ou similaire)
   - **Database Password** : (celui que vous avez défini)

### Option B : Via MySQL sur le VPS

Si vous avez accès root MySQL :

```bash
# Se connecter à MySQL en tant que root
sudo mysql -u root

# OU si un mot de passe root est défini
mysql -u root -p
```

Une fois connecté :

```sql
-- Voir les bases de données
SHOW DATABASES;

-- Voir les utilisateurs
SELECT user, host FROM mysql.user;

-- Voir les permissions d'un utilisateur
SHOW GRANTS FOR 'votre_utilisateur'@'localhost';
```

---

## 🔧 Étape 3 : Créer/Configurer un Utilisateur MySQL

### Si vous avez accès root MySQL

```bash
mysql -u root -p
```

Puis dans MySQL :

```sql
-- Créer la base de données si elle n'existe pas
CREATE DATABASE IF NOT EXISTS u133413376_auxivie CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Créer un utilisateur (remplacez 'mot_de_passe' par un mot de passe fort)
CREATE USER 'auxivie_user'@'localhost' IDENTIFIED BY 'votre_mot_de_passe_fort_ici';

-- Donner tous les privilèges
GRANT ALL PRIVILEGES ON u133413376_auxivie.* TO 'auxivie_user'@'localhost';

-- Appliquer les changements
FLUSH PRIVILEGES;

-- Vérifier
SHOW GRANTS FOR 'auxivie_user'@'localhost';

-- Quitter
EXIT;
```

### Si vous n'avez pas accès root

Utilisez les credentials depuis Hostinger hPanel.

---

## 📝 Étape 4 : Mettre à Jour le Fichier .env

Sur le VPS :

```bash
cd ~/backend/backend
nano .env
```

Modifiez les valeurs MySQL :

```env
# Configuration MySQL
DB_HOST=localhost
DB_USER=auxivie_user          # OU l'utilisateur depuis Hostinger
DB_PASSWORD=votre_mot_de_passe_fort_ici
DB_NAME=u133413376_auxivie
DB_PORT=3306
```

**Sauvegarder** : `Ctrl+X`, `Y`, `Entrée`

---

## ✅ Étape 5 : Tester la Connexion

### Test 1 : Depuis la ligne de commande

```bash
mysql -u auxivie_user -p u133413376_auxivie
```

Entrez le mot de passe. Si ça fonctionne, vous êtes connecté !

### Test 2 : Depuis Node.js

Créez un fichier de test :

```bash
cd ~/backend/backend
nano test-db.js
```

Contenu :

```javascript
require('dotenv').config();
const db = require('./db');

(async () => {
  const connected = await db.testConnection();
  if (connected) {
    console.log('✅ Connexion MySQL réussie !');
    process.exit(0);
  } else {
    console.log('❌ Échec de la connexion MySQL');
    process.exit(1);
  }
})();
```

Exécutez :

```bash
node test-db.js
```

---

## 🚀 Étape 6 : Redémarrer le Backend

Une fois la connexion testée :

```bash
cd ~/backend/backend

# Si vous utilisez PM2
pm2 restart auxivie-api

# OU si vous démarrez manuellement
npm start
```

Vous devriez voir :
```
✅ Connexion MySQL établie
✅ Base de données MySQL initialisée
🚀 Serveur API démarré sur http://localhost:3001
✅ Connexion MySQL établie
```

---

## 🐛 Problèmes Courants

### Problème : "Access denied" même avec les bons credentials

**Solutions :**
1. Vérifiez que l'utilisateur existe : `SELECT user FROM mysql.user;`
2. Vérifiez les permissions : `SHOW GRANTS FOR 'utilisateur'@'localhost';`
3. Réessayez de créer l'utilisateur avec `FLUSH PRIVILEGES;`

### Problème : "Unknown database"

**Solutions :**
1. Créez la base : `CREATE DATABASE u133413376_auxivie;`
2. Importez les données : `mysql -u utilisateur -p u133413376_auxivie < auxivie-mysql.sql`

### Problème : MySQL n'est pas installé

**Solutions :**
```bash
# Installer MySQL
sudo apt update
sudo apt install mysql-server

# Démarrer MySQL
sudo systemctl start mysql
sudo systemctl enable mysql

# Sécuriser l'installation
sudo mysql_secure_installation
```

---

## 📋 Checklist

- [ ] Credentials MySQL vérifiés dans Hostinger hPanel
- [ ] Fichier `.env` mis à jour avec les bons credentials
- [ ] Test de connexion MySQL réussi (`mysql -u user -p`)
- [ ] Test Node.js réussi (`node test-db.js`)
- [ ] Backend redémarré
- [ ] Logs vérifiés (pas d'erreur)

---

**Une fois la connexion établie, votre backend sera opérationnel ! 🎉**

