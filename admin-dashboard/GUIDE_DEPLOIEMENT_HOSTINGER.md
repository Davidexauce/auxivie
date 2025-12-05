# 🚀 Guide de Déploiement du Dashboard sur Hostinger

## 📋 Prérequis

- ✅ Compte Hostinger actif
- ✅ Compte GitHub avec le repository du projet
- ✅ Hostinger connecté à GitHub
- ✅ Node.js 18+ installé sur Hostinger

---

## 🔧 Configuration Initiale

### 1. Préparer le Repository GitHub

Assurez-vous que votre repository GitHub contient :
- ✅ Le dossier `admin-dashboard/`
- ✅ Les fichiers de configuration (`.env.example`, `package.json`, `next.config.js`)
- ✅ Le fichier `server.js` pour Hostinger

### 2. Variables d'Environnement

Créez un fichier `.env` dans le dossier `admin-dashboard/` avec :

```env
NEXT_PUBLIC_API_URL=https://api.auxivie.org
PORT=3000
NODE_ENV=production
```

**⚠️ Important :** Assurez-vous que votre API backend est accessible à l'URL `https://api.auxivie.org`

---

## 📦 Étapes de Déploiement sur Hostinger

### Étape 1 : Accéder au Panneau Hostinger

1. Connectez-vous à votre compte Hostinger
2. Accédez au **hPanel** (panneau de contrôle)
3. Allez dans **"Websites"** ou **"Advanced"** → **"Node.js"**

### Étape 2 : Créer une Application Node.js

1. Cliquez sur **"Create Node.js App"**
2. Configurez l'application :
   - **App Name** : `auxivie-admin-dashboard`
   - **Node.js Version** : `18.x` ou supérieur
   - **App Root** : `/admin-dashboard` (ou le chemin vers votre dossier)
   - **Start Command** : `npm start`
   - **Port** : `3000` (ou celui fourni par Hostinger)

### Étape 3 : Connecter GitHub

1. Dans la section **"Deployment"**, sélectionnez **"GitHub"**
2. Autorisez Hostinger à accéder à votre compte GitHub
3. Sélectionnez votre repository
4. Sélectionnez la branche (généralement `main` ou `master`)
5. Configurez le **"Source Directory"** : `/admin-dashboard`

### Étape 4 : Configurer les Variables d'Environnement

1. Dans la section **"Environment Variables"**, ajoutez :
   ```
   NEXT_PUBLIC_API_URL = https://api.auxivie.org
   NODE_ENV = production
   PORT = 3000
   ```

### Étape 5 : Déployer

1. Cliquez sur **"Deploy"** ou **"Save & Deploy"**
2. Attendez que le déploiement se termine (généralement 2-5 minutes)
3. Vérifiez les logs pour détecter d'éventuelles erreurs

---

## 🔍 Vérification du Déploiement

### 1. Vérifier les Logs

Dans le panneau Hostinger, consultez les logs de l'application pour vérifier :
- ✅ Que `npm install` s'est exécuté correctement
- ✅ Que `npm run build` s'est terminé sans erreur
- ✅ Que le serveur démarre sur le bon port

### 2. Tester l'Application

1. Accédez à votre domaine : `https://www.auxivie.org` (ou l'URL fournie par Hostinger)
2. Vérifiez que la page de login s'affiche
3. Testez la connexion avec vos identifiants admin

### 3. Vérifier la Connexion à l'API

- Ouvrez la console du navigateur (F12)
- Vérifiez qu'il n'y a pas d'erreurs CORS
- Vérifiez que les appels API fonctionnent

---

## 🛠️ Configuration du Domaine (Optionnel)

### Configuration du domaine auxivie.org :

1. Dans Hostinger, allez dans **"Domains"**
2. Vérifiez que `auxivie.org` est bien configuré
3. Configurez les DNS si nécessaire pour pointer vers votre application Node.js
4. Configurez un sous-domaine `www.auxivie.org` si nécessaire
5. Assurez-vous que `NEXT_PUBLIC_API_URL` pointe vers `https://api.auxivie.org`

---

## 🔄 Mise à Jour Continue

### Déploiement Automatique

Hostinger peut être configuré pour déployer automatiquement à chaque push sur GitHub :

1. Dans les paramètres de l'application Node.js
2. Activez **"Auto Deploy"**
3. Sélectionnez la branche (généralement `main`)

### Déploiement Manuel

Pour déployer manuellement :
1. Faites un push sur GitHub
2. Dans Hostinger, cliquez sur **"Redeploy"**

---

## ⚠️ Dépannage

### Problème : L'application ne démarre pas

**Solutions :**
- Vérifiez les logs dans Hostinger
- Vérifiez que `NODE_ENV=production` est défini
- Vérifiez que le port est correct
- Vérifiez que `npm start` est la bonne commande

### Problème : Erreurs 404

**Solutions :**
- Vérifiez que `next.config.js` est correctement configuré
- Vérifiez que le fichier `.htaccess` est présent (si nécessaire)
- Vérifiez que le routing Next.js fonctionne

### Problème : Erreurs CORS

**Solutions :**
- Vérifiez que `NEXT_PUBLIC_API_URL` est défini sur `https://api.auxivie.org`
- Vérifiez que le backend autorise les requêtes depuis `https://www.auxivie.org`
- Vérifiez les headers CORS dans le backend (doit inclure `https://www.auxivie.org` dans `Access-Control-Allow-Origin`)

### Problème : Variables d'environnement non chargées

**Solutions :**
- Vérifiez que les variables sont bien définies dans Hostinger
- Redémarrez l'application après avoir modifié les variables
- Vérifiez que les variables commencent par `NEXT_PUBLIC_` pour être accessibles côté client

---

## 📝 Checklist de Déploiement

- [ ] Repository GitHub configuré
- [ ] Fichier `.env.example` créé
- [ ] Variables d'env définies dans Hostinger
- [ ] Application Node.js créée dans Hostinger
- [ ] GitHub connecté à Hostinger
- [ ] Source directory configuré (`/admin-dashboard`)
- [ ] Build command : `npm run build`
- [ ] Start command : `npm start`
- [ ] Port configuré (3000 ou celui fourni)
- [ ] Déploiement réussi
- [ ] Application accessible via l'URL
- [ ] Login fonctionne
- [ ] Connexion à l'API fonctionne

---

## 🔐 Sécurité

### Recommandations :

1. **Ne jamais commiter le fichier `.env`** (déjà dans `.gitignore`)
2. **Utiliser HTTPS** pour toutes les communications
3. **Configurer les headers de sécurité** (déjà dans `next.config.js`)
4. **Limiter l'accès** au dashboard aux administrateurs uniquement
5. **Utiliser des tokens JWT** avec expiration

---

## 📞 Support

Si vous rencontrez des problèmes :
1. Consultez les logs dans Hostinger
2. Vérifiez la documentation Hostinger
3. Contactez le support Hostinger si nécessaire

---

**Date de création :** 2024-12-19  
**Dernière mise à jour :** 2024-12-19

