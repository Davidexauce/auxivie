# ✅ Vérification de la Structure Backend

## 📍 Structure Actuelle

Vous avez créé :
```
domains/auxivie.org/public_html/backend/data/
```

## ✅ C'est Correct !

Cette structure fonctionne parfaitement ! Le backend peut être dans `public_html/backend/`.

---

## 🔧 Configuration Node.js sur Hostinger

### App Root à Configurer

Dans Hostinger hPanel → Node.js :

**App Root :** `/domains/auxivie.org/public_html/backend`

OU

**App Root :** `/public_html/backend`

(Le chemin exact dépend de la configuration Hostinger)

---

## ✅ Checklist - Vérification

### 1. Structure des Dossiers

Vérifiez que vous avez :
- ✅ `public_html/backend/` (créé)
- ✅ `public_html/backend/data/` (créé)
- ✅ `public_html/backend/uploads/` (à créer si pas fait)
- ✅ `public_html/backend/uploads/documents/` (à créer)
- ✅ `public_html/backend/uploads/photos/` (à créer)

### 2. Fichiers Uploadés

Dans `public_html/backend/` :
- ✅ `server.js`
- ✅ `package.json`
- ✅ `package-lock.json`
- ✅ Dossier `scripts/`

Dans `public_html/backend/data/` :
- ✅ `auxivie.db` (80 KB)

### 3. Fichier .env

Dans `public_html/backend/` :
- ✅ Fichier `.env` créé avec :
  ```env
  PORT=3001
  NODE_ENV=production
  DB_PATH=./data/auxivie.db
  JWT_SECRET=votre_cle_secrete
  CORS_ORIGIN=https://www.auxivie.org
  UPLOADS_DIR=./uploads
  ```

---

## 🚀 Prochaines Étapes

### 1. Créer l'Application Node.js

Dans Hostinger hPanel → Node.js :

1. **"Create Node.js App"**
2. Configuration :
   - **App Name** : `auxivie-api`
   - **Node.js Version** : `18.x` ou `20.x`
   - **App Root** : `/domains/auxivie.org/public_html/backend`
     - OU essayez : `/public_html/backend`
     - OU : `domains/auxivie.org/public_html/backend`
   - **Start Command** : `npm start`
   - **Port** : `3001`

### 2. Installer les Dépendances

Dans le Terminal de l'application Node.js :
```bash
cd /domains/auxivie.org/public_html/backend
npm install --production
```

### 3. Démarrer l'Application

1. Cliquez sur **"Start"** dans Node.js Manager
2. Vérifiez les logs pour confirmer :
   ```
   🚀 Serveur API démarré sur http://localhost:3001
   ```

### 4. Tester l'API

Ouvrez dans un navigateur :
```
https://api.auxivie.org/api/users?userType=professionnel
```

---

## ⚠️ Note Importante

Si l'application Node.js ne démarre pas :

1. **Vérifiez le chemin App Root** dans la configuration
2. Essayez différents chemins :
   - `/domains/auxivie.org/public_html/backend`
   - `/public_html/backend`
   - `domains/auxivie.org/public_html/backend`
3. **Vérifiez les logs** pour voir les erreurs
4. **Vérifiez que `npm install` a été exécuté**

---

## ✅ Si Tout Est OK

Une fois que :
- ✅ Les fichiers sont uploadés
- ✅ Le `.env` est créé
- ✅ L'application Node.js est créée et démarrée
- ✅ L'API répond correctement

**Votre backend sera opérationnel ! 🎉**

---

## 🆘 Besoin d'Aide ?

Si vous rencontrez des problèmes :
1. Vérifiez les logs dans Node.js Manager
2. Vérifiez que tous les fichiers sont bien uploadés
3. Vérifiez les permissions (644 pour .db, 600 pour .env)
4. Vérifiez que `npm install` a bien installé les dépendances

