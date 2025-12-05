# ⚡ Guide Rapide - Déploiement Backend Hostinger

## 🎯 Situation

- ✅ Dashboard dans `public_html/`
- ❌ Backend **pas encore déployé**

---

## 📋 Étapes Rapides

### 1️⃣ Créer le Dossier Backend

**Dans le File Manager Hostinger :**
1. Naviguez vers : `domains/auxivie.org/`
2. **Clic droit** → **"New Folder"**
3. Nommez : `backend`
4. Appuyez sur **Entrée**

### 2️⃣ Créer les Sous-Dossiers

**Dans `backend/` :**
1. Créez `data/`
2. Créez `uploads/`
3. Dans `uploads/`, créez `documents/` et `photos/`

### 3️⃣ Uploader les Fichiers Essentiels

**Depuis votre Mac :**
- Ouvrez le Finder
- Allez dans : `/Users/david/Christelle Projet/backend/`

**Fichiers à uploader dans `backend/` :**
- ✅ `server.js`
- ✅ `package.json`
- ✅ `package-lock.json` (si présent)
- ✅ Dossier `scripts/` (entier)

**Fichier à uploader dans `backend/data/` :**
- ✅ `auxivie.db` (80 KB)

### 4️⃣ Créer le Fichier `.env`

**Dans `backend/` :**
1. **Clic droit** → **"New File"**
2. Nommez : `.env`
3. **Collez ce contenu :**

```env
PORT=3001
NODE_ENV=production
DB_PATH=./data/auxivie.db
JWT_SECRET=changez_cette_cle_par_une_cle_aleatoire_secrete
CORS_ORIGIN=https://www.auxivie.org
UPLOADS_DIR=./uploads
```

**⚠️ Important :** Changez `JWT_SECRET` par une clé aléatoire (ex: `abc123xyz789secret456`)

### 5️⃣ Installer les Dépendances

**Option A : Via SSH (Recommandé)**
```bash
cd domains/auxivie.org/backend
npm install --production
```

**Option B : Via Terminal dans Node.js Manager**
1. Dans hPanel → **"Node.js"**
2. Créez une application Node.js
3. **App Root** : `/domains/auxivie.org/backend`
4. **Start Command** : `npm start`
5. Ouvrez le terminal et exécutez : `npm install --production`

### 6️⃣ Configurer les Permissions

**Dans le File Manager :**
- `.env` → Permissions `600`
- `auxivie.db` → Permissions `644` ou `666`
- Dossiers → Permissions `755`

### 7️⃣ Démarrer l'Application

1. Dans hPanel → **"Node.js"**
2. Trouvez votre application
3. **Start Command** : `npm start`
4. **Port** : `3001`
5. Cliquez sur **"Start"**

### 8️⃣ Tester

Ouvrez dans un navigateur :
```
https://api.auxivie.org/api/users?userType=professionnel
```

---

## ✅ Checklist

- [ ] Dossier `backend/` créé
- [ ] Dossiers `data/`, `uploads/` créés
- [ ] Fichiers uploadés (`server.js`, `package.json`, etc.)
- [ ] Base de données `auxivie.db` uploadée
- [ ] Fichier `.env` créé
- [ ] Dépendances installées (`npm install`)
- [ ] Permissions configurées
- [ ] Application Node.js créée et démarrée
- [ ] API testée et fonctionnelle

---

**C'est tout ! 🎉**

Pour plus de détails, consultez `GUIDE_DEPLOIEMENT_BACKEND_HOSTINGER.md`

