# 📁 Structure du Projet pour Déploiement Hostinger

## 📋 Structure Actuelle du Repository GitHub

```
auxivie/
├── admin-dashboard/          ← Dashboard Next.js (à déployer dans public_html/admin_dashboard/)
│   ├── .env.example
│   ├── .gitignore
│   ├── .htaccess
│   ├── hostinger.json
│   ├── next.config.js
│   ├── package.json
│   ├── server.js
│   ├── components/
│   ├── lib/
│   ├── pages/
│   ├── public/
│   ├── scripts/
│   └── styles/
├── backend/                  ← Backend Node.js (déjà sur VPS)
│   ├── server.js
│   ├── db.js
│   ├── package.json
│   └── ...
└── lib/                       ← Application Flutter (mobile)
    └── ...
```

---

## 🎯 Configuration Déploiement Hostinger

### Pour le Dashboard (admin-dashboard/)

**Dossier source** : `admin-dashboard/`  
**Dossier de destination sur Hostinger** : `public_html/admin_dashboard/`

**Fichiers essentiels à déployer** :
- ✅ Tous les fichiers `.js`, `.json`, `.css`
- ✅ `next.config.js`
- ✅ `package.json`
- ✅ `server.js`
- ✅ `.htaccess`
- ✅ `hostinger.json`
- ✅ Dossiers : `components/`, `lib/`, `pages/`, `public/`, `styles/`

**Fichiers à créer sur Hostinger** (non trackés) :
- `.env.production` (avec `NEXT_PUBLIC_API_URL=https://api.auxivie.org`)

---

## 📋 Configuration Hostinger

### Option 1 : Déploiement Automatique depuis GitHub

Dans hPanel Hostinger :

1. **Allez dans "Git"** ou **"GitHub Deploy"**
2. **Connectez votre repository** : `https://github.com/Davidexauce/auxivie`
3. **Configurez le déploiement** :
   - **Dossier source** : `admin-dashboard/`
   - **Dossier de destination** : `public_html/admin_dashboard/`
   - **Branche** : `master`
4. **Activez le déploiement automatique**

### Option 2 : Déploiement Manuel

1. **Clonez le repository** sur Hostinger
2. **Copiez** `admin-dashboard/` vers `public_html/admin_dashboard/`
3. **Créez** `.env.production` avec la bonne URL

---

## ✅ Checklist Déploiement

- [ ] Repository GitHub à jour
- [ ] Fichier `hostinger.json` configuré
- [ ] Fichier `.env.example` présent
- [ ] Déploiement automatique configuré dans hPanel
- [ ] Fichier `.env.production` créé sur Hostinger
- [ ] Node.js activé sur Hostinger
- [ ] Dépendances installées (`npm install`)
- [ ] Dashboard buildé (`npm run build`)
- [ ] Serveur démarré (`npm start` ou PM2)

---

**Le Dashboard est maintenant prêt pour le déploiement automatique depuis GitHub !**

