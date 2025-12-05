# 🚀 Action Immédiate - Déploiement Backend

## 📍 Votre Situation

- ✅ Dashboard : `domains/auxivie.org/public_html/` (déjà déployé)
- ❌ Backend : **À créer dans** `domains/auxivie.org/backend/`

---

## ⚡ Actions à Faire MAINTENANT

### 1️⃣ Dans Hostinger File Manager

**Chemin actuel :** `domains/auxivie.org/public_html/`

**Actions :**
1. **Remontez d'un niveau** (cliquez sur `auxivie.org`)
2. **Créez le dossier `backend/`**
   - Clic droit → "New Folder" → `backend`
3. **Ouvrez `backend/`**
4. **Créez les sous-dossiers :**
   - `data/`
   - `uploads/`
   - Dans `uploads/`, créez `documents/` et `photos/`

### 2️⃣ Uploader les Fichiers

**Le Finder est maintenant ouvert avec votre dossier backend !**

**Fichiers à glisser-déposer dans `backend/` :**
- ✅ `server.js`
- ✅ `package.json`
- ✅ `package-lock.json`
- ✅ Dossier `scripts/` (entier)

**Fichier à glisser-déposer dans `backend/data/` :**
- ✅ `auxivie.db` (80 KB)

### 3️⃣ Créer le Fichier `.env`

**Dans `backend/` :**
1. Clic droit → "New File" → `.env`
2. Collez ce contenu :

```env
PORT=3001
NODE_ENV=production
DB_PATH=./data/auxivie.db
JWT_SECRET=ma_cle_secrete_auxivie_2024_changez_moi
CORS_ORIGIN=https://www.auxivie.org
UPLOADS_DIR=./uploads
```

### 4️⃣ Installer et Démarrer

**Dans Hostinger hPanel :**
1. Allez dans **"Advanced"** → **"Node.js"**
2. **"Create Node.js App"**
3. Configuration :
   - **App Name** : `auxivie-api`
   - **App Root** : `/domains/auxivie.org/backend`
   - **Start Command** : `npm start`
   - **Port** : `3001`
4. **Ouvrez le Terminal** de l'application
5. Exécutez : `npm install --production`
6. **Démarrez** l'application

### 5️⃣ Tester

Ouvrez : `https://api.auxivie.org/api/users?userType=professionnel`

---

## 📋 Checklist Rapide

- [ ] Dossier `backend/` créé dans Hostinger
- [ ] Dossiers `data/`, `uploads/` créés
- [ ] Fichiers uploadés (server.js, package.json, scripts/)
- [ ] `auxivie.db` uploadé dans `data/`
- [ ] Fichier `.env` créé
- [ ] Application Node.js créée
- [ ] `npm install` exécuté
- [ ] Application démarrée
- [ ] API testée

---

**C'est parti ! 🎉**

