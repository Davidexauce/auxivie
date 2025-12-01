# 🚀 Guide de Déploiement Étape par Étape - Auxivie

Ce guide vous accompagne pas à pas pour déployer votre application en production.

---

## 📋 ÉTAPE 1 : Préparation Locale

### 1.1 Vérifier les prérequis

Vérifiez que vous avez installé :
```bash
# Node.js
node --version  # Doit être 18 ou supérieur

# npm
npm --version

# Flutter
flutter --version

# Git
git --version
```

### 1.2 Créer les fichiers d'environnement

```bash
# Depuis la racine du projet
./setup-env.sh
```

Ou manuellement :
```bash
# Backend
cd backend
cp .env.example .env.production

# Dashboard
cd ../admin-dashboard
cp .env.example .env.production
```

### 1.3 Générer un JWT_SECRET fort

```bash
openssl rand -base64 32
```

**Copiez le résultat** - vous en aurez besoin pour l'étape suivante.

### 1.4 Configurer les fichiers .env.production

#### Backend (`backend/.env.production`)
```env
NODE_ENV=production
PORT=3001
JWT_SECRET=COLLEZ-LE-SECRET-GÉNÉRÉ-ICI
DB_PATH=./data/auxivie.db
CORS_ORIGIN=https://dashboard.votre-domaine.com,https://api.votre-domaine.com
API_URL=https://api.votre-domaine.com
```

**Remplacez `votre-domaine.com` par votre vrai domaine.**

#### Dashboard (`admin-dashboard/.env.production`)
```env
NEXT_PUBLIC_API_URL=https://api.votre-domaine.com
NODE_ENV=production
```

### 1.5 Configurer Flutter pour la production

Éditez `lib/config/app_config.dart` :

```dart
static const Environment _currentEnvironment = Environment.production;

// Dans le switch case :
case Environment.production:
  return 'https://api.votre-domaine.com';  // Votre URL API
```

---

## 📦 ÉTAPE 2 : Tests Locaux

### 2.1 Tester le backend localement

```bash
cd backend

# Installer les dépendances
npm ci --only=production

# Tester le démarrage
NODE_ENV=production node server.js
```

Vérifiez que le serveur démarre sur `http://localhost:3001`

### 2.2 Tester le dashboard localement

```bash
cd admin-dashboard

# Installer les dépendances
npm ci

# Build de production
npm run build

# Démarrer
npm start
```

Vérifiez que le dashboard démarre sur `http://localhost:3000`

### 2.3 Tester l'application Flutter

```bash
# Build Android
flutter build apk --release

# Ou build iOS
flutter build ios --release
```

---

## 🌐 ÉTAPE 3 : Préparer le Serveur

### 3.1 Choisir un hébergeur

Options recommandées :
- **DigitalOcean** (VPS simple, ~$6/mois)
- **AWS EC2** (plus complexe, plus puissant)
- **Heroku** (simple mais limité)
- **Vercel** (pour le Dashboard uniquement)

### 3.2 Se connecter au serveur

```bash
ssh root@votre-serveur-ip
```

### 3.3 Installer les dépendances système

```bash
# Mettre à jour le système
apt update && apt upgrade -y

# Installer Node.js 18
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

# Installer PM2
npm install -g pm2

# Installer Nginx
apt install -y nginx

# Installer Certbot (pour SSL)
apt install -y certbot python3-certbot-nginx

# Installer Git
apt install -y git
```

### 3.4 Créer un utilisateur pour l'application

```bash
# Créer un utilisateur
adduser auxivie
usermod -aG sudo auxivie

# Passer à cet utilisateur
su - auxivie
```

---

## 📥 ÉTAPE 4 : Déployer le Code

### 4.1 Cloner le projet sur le serveur

```bash
# Sur le serveur
cd /home/auxivie
git clone https://github.com/votre-repo/auxivie.git
cd auxivie
```

**OU** transférer les fichiers via SCP :
```bash
# Depuis votre machine locale
scp -r /Users/david/Christelle\ Projet/* auxivie@votre-serveur:/home/auxivie/auxivie/
```

### 4.2 Configurer les variables d'environnement sur le serveur

```bash
cd /home/auxivie/auxivie

# Backend
cd backend
nano .env.production
# Collez vos valeurs (JWT_SECRET, domaines, etc.)

# Dashboard
cd ../admin-dashboard
nano .env.production
# Collez vos valeurs
```

---

## 🔧 ÉTAPE 5 : Déployer le Backend

### 5.1 Installer les dépendances

```bash
cd /home/auxivie/auxivie/backend
npm ci --only=production
```

### 5.2 Créer les répertoires nécessaires

```bash
mkdir -p data logs backups
```

### 5.3 Initialiser la base de données

```bash
node scripts/init-db.js
```

### 5.4 Démarrer avec PM2

```bash
pm2 start ecosystem.config.js --env production
pm2 save
pm2 startup
# Suivez les instructions affichées
```

### 5.5 Vérifier que le backend fonctionne

```bash
pm2 status
pm2 logs auxivie-backend
```

Testez l'API :
```bash
curl http://localhost:3001/api/health
```

---

## 🎨 ÉTAPE 6 : Déployer le Dashboard

### Option A : Sur Vercel (Recommandé - Plus Simple)

1. **Installer Vercel CLI** (sur votre machine locale) :
```bash
npm install -g vercel
```

2. **Déployer** :
```bash
cd admin-dashboard
vercel --prod
```

3. **Configurer les variables d'environnement** dans le dashboard Vercel :
   - `NEXT_PUBLIC_API_URL` = `https://api.votre-domaine.com`

### Option B : Sur le même serveur

```bash
cd /home/auxivie/auxivie/admin-dashboard
npm ci
npm run build

# Démarrer avec PM2
pm2 start npm --name "auxivie-dashboard" -- start
pm2 save
```

---

## 🌍 ÉTAPE 7 : Configurer les Domaines

### 7.1 Configurer les DNS

Dans votre gestionnaire de domaine, ajoutez :

```
A    api.votre-domaine.com    →    IP_DE_VOTRE_SERVEUR
A    dashboard.votre-domaine.com  →  IP_DE_VOTRE_SERVEUR
```

**OU** si vous utilisez Vercel pour le dashboard :
```
CNAME  dashboard.votre-domaine.com  →  cname.vercel-dns.com
```

### 7.2 Configurer Nginx

Créez `/etc/nginx/sites-available/auxivie-api` :

```nginx
server {
    listen 80;
    server_name api.votre-domaine.com;

    location / {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

Si le dashboard est sur le même serveur, créez aussi `/etc/nginx/sites-available/auxivie-dashboard` :

```nginx
server {
    listen 80;
    server_name dashboard.votre-domaine.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

Activer les sites :
```bash
ln -s /etc/nginx/sites-available/auxivie-api /etc/nginx/sites-enabled/
ln -s /etc/nginx/sites-available/auxivie-dashboard /etc/nginx/sites-enabled/

# Tester la configuration
nginx -t

# Redémarrer Nginx
systemctl restart nginx
```

### 7.3 Installer SSL avec Let's Encrypt

```bash
# Pour l'API
certbot --nginx -d api.votre-domaine.com

# Pour le Dashboard (si sur le même serveur)
certbot --nginx -d dashboard.votre-domaine.com

# Renouvellement automatique
certbot renew --dry-run
```

---

## 📱 ÉTAPE 8 : Configurer l'Application Flutter

### 8.1 Mettre à jour l'URL de l'API

Dans `lib/config/app_config.dart`, assurez-vous que :
```dart
case Environment.production:
  return 'https://api.votre-domaine.com';
```

### 8.2 Build pour Android

```bash
# APK (pour distribution directe)
flutter build apk --release

# App Bundle (pour Google Play Store)
flutter build appbundle --release
```

Les fichiers seront dans :
- APK : `build/app/outputs/flutter-apk/app-release.apk`
- AAB : `build/app/outputs/bundle/release/app-release.aab`

### 8.3 Build pour iOS

```bash
flutter build ios --release
```

Puis ouvrez Xcode et archivez pour l'App Store.

---

## ✅ ÉTAPE 9 : Vérifications Finales

### 9.1 Tester l'API

```bash
# Health check
curl https://api.votre-domaine.com/api/health

# Devrait retourner : {"status":"ok","message":"Auxivie API"}
```

### 9.2 Tester le Dashboard

Ouvrez dans votre navigateur :
```
https://dashboard.votre-domaine.com
```

Connectez-vous avec les identifiants admin.

### 9.3 Tester l'Application

Installez l'APK sur un téléphone Android ou testez l'app iOS.

Vérifiez que :
- ✅ La connexion fonctionne
- ✅ Les données se chargent
- ✅ Les messages fonctionnent
- ✅ Les réservations fonctionnent

---

## 🔒 ÉTAPE 10 : Sécurité et Optimisations

### 10.1 Configurer le Firewall

```bash
# Autoriser SSH, HTTP, HTTPS
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp

# Activer le firewall
ufw enable
```

### 10.2 Configurer les Backups Automatiques

```bash
# Éditer le crontab
crontab -e

# Ajouter cette ligne (backup quotidien à 2h du matin)
0 2 * * * cd /home/auxivie/auxivie/backend && node scripts/backup-db.js
```

### 10.3 Monitoring avec PM2

```bash
# Voir les logs
pm2 logs

# Monitoring en temps réel
pm2 monit

# Redémarrer si nécessaire
pm2 restart auxivie-backend
```

---

## 🆘 Dépannage

### Le backend ne démarre pas

```bash
# Vérifier les logs
pm2 logs auxivie-backend

# Vérifier les variables d'environnement
cd backend
cat .env.production

# Tester manuellement
NODE_ENV=production node server.js
```

### Le dashboard ne se connecte pas à l'API

1. Vérifiez `NEXT_PUBLIC_API_URL` dans `.env.production`
2. Vérifiez CORS dans `backend/.env.production`
3. Vérifiez que l'API est accessible : `curl https://api.votre-domaine.com/api/health`

### L'application ne se connecte pas

1. Vérifiez l'URL dans `lib/config/app_config.dart`
2. Vérifiez que l'API est accessible depuis Internet
3. Vérifiez les logs du backend : `pm2 logs auxivie-backend`

### Erreurs SSL

```bash
# Renouveler le certificat
certbot renew

# Vérifier la configuration Nginx
nginx -t
systemctl restart nginx
```

---

## 📊 Checklist de Déploiement

- [ ] Fichiers .env.production configurés
- [ ] JWT_SECRET généré et configuré
- [ ] Backend testé localement
- [ ] Dashboard testé localement
- [ ] Serveur préparé (Node.js, PM2, Nginx)
- [ ] Code déployé sur le serveur
- [ ] Backend démarré avec PM2
- [ ] Dashboard déployé (Vercel ou serveur)
- [ ] Domaines configurés (DNS)
- [ ] Nginx configuré
- [ ] SSL installé (Let's Encrypt)
- [ ] Application Flutter buildée
- [ ] Tests de connexion réussis
- [ ] Firewall configuré
- [ ] Backups automatiques configurés

---

## 🎉 Félicitations !

Votre application est maintenant en production ! 

Pour toute question, consultez :
- `DEPLOYMENT.md` - Guide détaillé
- `DEPLOYMENT_CHECKLIST.md` - Checklist complète
- Les logs PM2 : `pm2 logs`

