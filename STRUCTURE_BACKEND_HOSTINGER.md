# 📁 Structure du Backend sur Hostinger

## 📍 Chemin Complet

```
domains/
└── auxivie.org/
    ├── public_html/          ← Dashboard (déjà déployé)
    └── backend/              ← Backend API (à créer)
        ├── data/
        │   └── auxivie.db    ← Base de données (80 KB)
        ├── uploads/
        │   ├── documents/     ← Documents uploadés
        │   └── photos/       ← Photos de profil
        ├── scripts/          ← Scripts utilitaires
        ├── node_modules/     ← Dépendances (généré par npm)
        ├── server.js         ← Fichier principal
        ├── package.json      ← Configuration npm
        ├── package-lock.json ← Verrouillage des versions
        └── .env              ← Variables d'environnement
```

---

## 🎯 Actions à Effectuer

### 1. Créer le Dossier `backend/`

**Dans le File Manager :**
- Naviguez vers : `domains/auxivie.org/`
- Clic droit → "New Folder"
- Nommez : `backend`

### 2. Créer les Sous-Dossiers

**Dans `backend/` :**
- `data/` → Pour la base de données
- `uploads/documents/` → Pour les documents
- `uploads/photos/` → Pour les photos

### 3. Uploader les Fichiers

**Fichiers essentiels :**
- `server.js`
- `package.json`
- `package-lock.json` (si présent)
- Dossier `scripts/` (entier)

**Fichier base de données :**
- `data/auxivie.db` (80 KB)

**Fichier de configuration :**
- `.env` (à créer manuellement)

---

## 📝 Fichier `.env` à Créer

Créez un fichier `.env` dans `backend/` avec ce contenu :

```env
PORT=3001
NODE_ENV=production
DB_PATH=./data/auxivie.db
JWT_SECRET=votre_cle_secrete_aleatoire_ici
CORS_ORIGIN=https://www.auxivie.org
UPLOADS_DIR=./uploads
```

---

## ✅ Ordre d'Exécution

1. ✅ Créer `backend/` dans File Manager
2. ✅ Créer `data/`, `uploads/documents/`, `uploads/photos/`
3. ✅ Uploader `server.js`, `package.json`, `scripts/`
4. ✅ Créer `.env` avec les variables
5. ✅ Installer dépendances : `npm install --production`
6. ✅ Uploader `auxivie.db` dans `data/`
7. ✅ Configurer permissions (644 pour .db, 600 pour .env)
8. ✅ Créer application Node.js dans Hostinger
9. ✅ Démarrer l'application
10. ✅ Tester l'API

---

**Structure prête ! 🎉**

