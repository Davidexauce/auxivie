# 🚀 Déployer le Dashboard sur Hostinger via File Manager

## 📋 Situation Actuelle

- ✅ Dashboard disponible sur GitHub : `https://github.com/Davidexauce/auxivie.git`
- ❌ Dashboard **non déployé** sur Hostinger
- 📁 Dans `public_html` : seulement `api/` et `node_modules/`

---

## 🎯 Solution : Déployer via File Manager

### Étape 1 : Télécharger le Dashboard depuis GitHub

1. **Allez sur GitHub** : https://github.com/Davidexauce/auxivie
2. **Cliquez sur le bouton vert "Code"** → **"Download ZIP"**
3. **Téléchargez** le fichier `auxivie-master.zip` (ou similaire)

### Étape 2 : Extraire le Dossier admin-dashboard

Sur votre machine locale :

1. **Extrayez** le fichier ZIP
2. **Ouvrez** le dossier `auxivie-master`
3. **Trouvez** le dossier `admin-dashboard`
4. **Compressez** le dossier `admin-dashboard` en ZIP

### Étape 3 : Uploader sur Hostinger

1. **Connectez-vous à hPanel** : https://hpanel.hostinger.com/
2. **Ouvrez File Manager**
3. **Naviguez vers** : `domains/auxivie.org/public_html/`
4. **Cliquez sur "Upload"** ou **"Téléverser"**
5. **Uploadez** le ZIP du dossier `admin-dashboard`
6. **Extrayez** le ZIP dans `public_html/`
7. **Renommez** le dossier en `admin_dashboard` (avec underscore, comme vous l'avez mentionné)

### Étape 4 : Créer le Fichier .env.production

Dans le File Manager :

1. **Naviguez vers** : `domains/auxivie.org/public_html/admin_dashboard/`
2. **Créez un nouveau fichier** : `.env.production`
3. **Collez ce contenu** :
   ```
   NEXT_PUBLIC_API_URL=https://api.auxivie.org
   ```
4. **Sauvegardez**

---

## 🎯 Solution Alternative : Via SSH (si disponible)

Si vous avez accès SSH :

```bash
# 1. Aller dans public_html
cd ~/domains/auxivie.org/public_html

# 2. Cloner le repository
git clone https://github.com/Davidexauce/auxivie.git temp

# 3. Déplacer le dossier admin-dashboard
mv temp/admin-dashboard admin_dashboard

# 4. Nettoyer
rm -rf temp

# 5. Aller dans admin_dashboard
cd admin_dashboard

# 6. Installer les dépendances
npm install

# 7. Créer .env.production
echo "NEXT_PUBLIC_API_URL=https://api.auxivie.org" > .env.production

# 8. Build
npm run build

# 9. Démarrer (ou configurer PM2)
npm start
```

---

## 📋 Structure Finale Attendue

Après déploiement, vous devriez avoir :

```
public_html/
├── api/                    (existant)
├── node_modules/           (existant)
└── admin_dashboard/        (NOUVEAU)
    ├── .env.production
    ├── package.json
    ├── next.config.js
    ├── server.js
    ├── lib/
    ├── pages/
    ├── components/
    └── ...
```

---

## ✅ Vérification

Après le déploiement :

1. **Vérifiez** que le dossier `admin_dashboard` existe dans `public_html`
2. **Vérifiez** que `.env.production` existe et contient la bonne URL
3. **Installez les dépendances** : `npm install` (via SSH ou Terminal Hostinger)
4. **Build** : `npm run build`
5. **Démarrez** : `npm start` ou configurez PM2

---

**Le Dashboard doit être déployé manuellement car il n'est pas encore sur Hostinger !**

