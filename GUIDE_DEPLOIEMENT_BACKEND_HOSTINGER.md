# 🚀 Guide de Déploiement du Backend sur Hostinger

## 📍 Situation Actuelle

Vous avez :
- ✅ Dashboard déployé dans `public_html/`
- ❌ Backend API **pas encore déployé**

Le backend doit être déployé **séparément** via Node.js sur Hostinger.

---

## 🎯 Objectif

Déployer le backend API Node.js sur Hostinger pour que :
- Le dashboard puisse communiquer avec l'API
- L'application Flutter puisse communiquer avec l'API
- La base de données soit accessible

---

## 📋 Étape 1 : Créer l'Application Node.js sur Hostinger

### 1.1 Accéder au Panneau Node.js

1. **Connectez-vous à Hostinger hPanel**
2. Allez dans **"Advanced"** → **"Node.js"**
   - OU **"Websites"** → **"Node.js"**

### 1.2 Créer une Nouvelle Application

1. Cliquez sur **"Create Node.js App"** ou **"Créer une application"**
2. Configurez l'application :

   **Configuration :**
   - **App Name** : `auxivie-api` ou `backend-api`
   - **Node.js Version** : `18.x` ou `20.x` (recommandé)
   - **App Root** : `/backend` ou `/domains/auxivie.org/backend`
   - **Start Command** : `npm start` ou `node server.js`
   - **Port** : `3001` (ou celui configuré dans votre `.env`)

3. Cliquez sur **"Create"** ou **"Créer"**

---

## 📁 Étape 2 : Uploader les Fichiers du Backend

### 2.1 Via File Manager

1. **Ouvrez le File Manager** dans Hostinger
2. **Naviguez vers** : `domains/auxivie.org/`
3. **Créez le dossier `backend/`** (s'il n'existe pas)
   - Clic droit → "New Folder" → Nommez `backend`

4. **Dans le dossier `backend/`, créez la structure :**
   ```
   backend/
   ├── data/          ← Pour la base de données
   ├── uploads/       ← Pour les fichiers uploadés
   │   ├── documents/
   │   └── photos/
   ├── scripts/       ← Scripts utilitaires
   ├── server.js      ← Fichier principal
   ├── package.json   ← Dépendances
   └── .env           ← Variables d'environnement
   ```

### 2.2 Uploader les Fichiers

**Méthode A : Via File Manager (Glisser-Déposer)**

1. **Sur votre Mac**, ouvrez le Finder
2. **Naviguez vers** : `/Users/david/Christelle Projet/backend/`
3. **Sélectionnez ces fichiers/dossiers :**
   - `server.js`
   - `package.json`
   - `package-lock.json` (si présent)
   - Dossier `scripts/` (entier)
4. **Glissez-déposez** dans le File Manager de Hostinger dans `domains/auxivie.org/backend/`

**Méthode B : Via FTP**

1. Obtenez les identifiants FTP dans Hostinger
2. Utilisez FileZilla ou un autre client FTP
3. Connectez-vous
4. Naviguez vers `domains/auxivie.org/backend/`
5. Uploader les fichiers

**Méthode C : Via Git (Recommandé)**

Si votre repository GitHub contient le backend :

1. Dans Hostinger, utilisez **"Git"** dans le hPanel
2. Clonez votre repository
3. Configurez le déploiement automatique

---

## 🔧 Étape 3 : Configurer les Variables d'Environnement

### 3.1 Créer le Fichier `.env`

Dans le File Manager, dans `domains/auxivie.org/backend/` :

1. **Créez un nouveau fichier** nommé `.env`
2. **Ajoutez ce contenu :**

```env
# Port du serveur
PORT=3001

# Environnement
NODE_ENV=production

# Base de données SQLite
DB_PATH=./data/auxivie.db

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

**⚠️ Important :**
- Remplacez `JWT_SECRET` par une clé secrète aléatoire (générez-en une avec un générateur)
- Si vous utilisez Stripe, ajoutez vos clés API
- `CORS_ORIGIN` doit pointer vers votre dashboard

### 3.2 Permissions du Fichier `.env`

- Clic droit sur `.env` → "Change Permissions"
- Entrez `600` (lecture/écriture pour le propriétaire uniquement)

---

## 📦 Étape 4 : Installer les Dépendances

### 4.1 Via Terminal SSH (Recommandé)

1. Dans Hostinger hPanel, allez dans **"Advanced"** → **"SSH Access"**
2. **Activez SSH** si ce n'est pas déjà fait
3. **Connectez-vous via SSH** :
   ```bash
   ssh votre_utilisateur@votre_serveur_hostinger
   ```
4. **Naviguez vers le dossier backend :**
   ```bash
   cd domains/auxivie.org/backend
   ```
5. **Installez les dépendances :**
   ```bash
   npm install --production
   ```

### 4.2 Via Node.js Manager dans hPanel

1. Dans **"Node.js"**, trouvez votre application `auxivie-api`
2. Cliquez sur **"Open Terminal"** ou **"Terminal"**
3. Exécutez :
   ```bash
   cd backend
   npm install --production
   ```

---

## 💾 Étape 5 : Uploader la Base de Données

### 5.1 Créer le Dossier `data/`

1. Dans le File Manager, dans `domains/auxivie.org/backend/`
2. **Créez le dossier `data/`**
   - Clic droit → "New Folder" → Nommez `data`

### 5.2 Uploader `auxivie.db`

1. **Ouvrez le dossier `data/`**
2. **Cliquez sur "Upload"**
3. **Glissez-déposez** le fichier `auxivie.db` depuis votre Mac
   - Chemin local : `/Users/david/Christelle Projet/backend/data/auxivie.db`
4. **Attendez** que l'upload se termine (~80 KB)

### 5.3 Permissions de la Base de Données

1. **Clic droit** sur `auxivie.db`
2. **"Change Permissions"**
3. **Entrez** : `644` ou `666`
4. **Cliquez "Change"**

---

## 📁 Étape 6 : Créer les Dossiers d'Upload

1. Dans `domains/auxivie.org/backend/`, créez :
   - `uploads/`
   - `uploads/documents/`
   - `uploads/photos/`

2. **Permissions** : `755` pour les dossiers

---

## 🚀 Étape 7 : Démarrer l'Application

### 7.1 Dans Node.js Manager

1. Dans **"Node.js"**, trouvez votre application `auxivie-api`
2. **Vérifiez la configuration :**
   - **App Root** : `/domains/auxivie.org/backend`
   - **Start Command** : `npm start` ou `node server.js`
   - **Port** : `3001`
3. **Cliquez sur "Start"** ou **"Démarrer"**

### 7.2 Vérifier les Logs

1. Cliquez sur **"View Logs"** ou **"Logs"**
2. Vous devriez voir :
   ```
   🚀 Serveur API démarré sur http://localhost:3001
   Base de données initialisée
   ```

---

## 🌐 Étape 8 : Configurer le Domaine API

### 8.1 Créer un Sous-Domaine

1. Dans Hostinger hPanel, allez dans **"Domains"** → **"Subdomains"**
2. **Créez un sous-domaine :**
   - **Subdomain** : `api`
   - **Domain** : `auxivie.org`
   - **Document Root** : `/domains/auxivie.org/backend` (ou laissez vide)
3. **Cliquez "Create"**

### 8.2 Configurer le Proxy (si nécessaire)

Si vous utilisez un reverse proxy :

1. Dans **"Advanced"** → **"Apache Configuration"**
2. Ajoutez une configuration pour rediriger `api.auxivie.org` vers `localhost:3001`

---

## ✅ Vérification

### 1. Tester l'API

Ouvrez un navigateur et testez :
```
https://api.auxivie.org/api/users?userType=professionnel
```

Vous devriez voir une réponse JSON avec les professionnels.

### 2. Tester depuis le Dashboard

1. Connectez-vous sur https://www.auxivie.org
2. Vérifiez que les utilisateurs s'affichent
3. Vérifiez que les autres fonctionnalités fonctionnent

### 3. Vérifier les Logs

Dans Node.js Manager → Logs, vérifiez qu'il n'y a **pas d'erreurs**.

---

## 🐛 Problèmes Courants

### "Cannot find module"

**Solution :**
- Vérifiez que `npm install` a été exécuté
- Vérifiez que `node_modules/` existe dans le dossier backend

### "Cannot open database"

**Solution :**
- Vérifiez que `auxivie.db` est dans `backend/data/`
- Vérifiez les permissions (644 ou 666)
- Vérifiez le chemin dans `.env` : `DB_PATH=./data/auxivie.db`

### "Port already in use"

**Solution :**
- Changez le port dans `.env` (par exemple `PORT=3002`)
- Redémarrez l'application

### "CORS error"

**Solution :**
- Vérifiez `CORS_ORIGIN` dans `.env`
- Assurez-vous que l'URL du dashboard est correcte

---

## 📋 Checklist Finale

- [ ] Application Node.js créée dans Hostinger
- [ ] Fichiers backend uploadés (`server.js`, `package.json`, etc.)
- [ ] Fichier `.env` créé et configuré
- [ ] Dépendances installées (`npm install`)
- [ ] Dossier `data/` créé
- [ ] Base de données `auxivie.db` uploadée
- [ ] Dossiers `uploads/` créés
- [ ] Permissions configurées
- [ ] Application démarrée
- [ ] Sous-domaine `api.auxivie.org` configuré
- [ ] API testée et fonctionnelle
- [ ] Dashboard connecté à l'API

---

**Une fois terminé, votre backend sera accessible sur `https://api.auxivie.org` ! 🎉**

