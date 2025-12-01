# 🚀 Guide de Déploiement - Auxivie

Ce guide vous accompagne dans le déploiement de l'application Auxivie en production.

## 📋 Prérequis

- Node.js 18+ installé
- npm ou yarn
- Un serveur VPS ou service cloud (AWS, DigitalOcean, Heroku, etc.)
- Un domaine (optionnel mais recommandé)
- Certificat SSL (Let's Encrypt gratuit)

## 🔧 Configuration

### 1. Backend API

#### Variables d'environnement

1. Copiez le fichier d'exemple :
```bash
cd backend
cp .env.example .env.production
```

2. Éditez `.env.production` avec vos valeurs :
```env
NODE_ENV=production
PORT=3001
JWT_SECRET=votre-secret-jwt-fort-et-unique
DB_PATH=./data/auxivie.db
CORS_ORIGIN=https://votre-dashboard.com,https://api.votre-domaine.com
API_URL=https://api.votre-domaine.com
```

**⚠️ Important** : Générez un JWT_SECRET fort :
```bash
openssl rand -base64 32
```

#### Installation des dépendances

```bash
cd backend
npm ci --only=production
```

#### Démarrage avec PM2 (Recommandé)

1. Installer PM2 globalement :
```bash
npm install -g pm2
```

2. Démarrer le backend :
```bash
pm2 start ecosystem.config.js --env production
pm2 save
pm2 startup  # Pour démarrer au boot
```

#### Démarrage manuel

```bash
NODE_ENV=production node server.js
```

### 2. Dashboard Admin

#### Variables d'environnement

1. Copiez le fichier d'exemple :
```bash
cd admin-dashboard
cp .env.example .env.production
```

2. Éditez `.env.production` :
```env
NEXT_PUBLIC_API_URL=https://api.votre-domaine.com
NODE_ENV=production
```

#### Build et démarrage

```bash
cd admin-dashboard
npm ci
npm run build
npm start
```

#### Déploiement sur Vercel (Recommandé)

1. Installez Vercel CLI :
```bash
npm install -g vercel
```

2. Déployez :
```bash
cd admin-dashboard
vercel --prod
```

### 3. Application Flutter

#### Configuration de l'URL API

1. Éditez `lib/config/app_config.dart` :
```dart
static const Environment _currentEnvironment = Environment.production;
```

2. Mettez à jour l'URL de production :
```dart
case Environment.production:
  return 'https://api.votre-domaine.com';
```

#### Build Android

```bash
flutter build apk --release
# ou pour App Bundle (recommandé pour Play Store)
flutter build appbundle --release
```

#### Build iOS

```bash
flutter build ios --release
```

## 🐳 Déploiement avec Docker

### Build et démarrage

```bash
# Depuis la racine du projet
docker-compose up -d
```

### Configuration

Éditez `docker-compose.yml` avec vos variables d'environnement.

## 🌐 Configuration Nginx (Reverse Proxy)

Exemple de configuration Nginx pour servir le backend et le dashboard :

```nginx
# Backend API
server {
    listen 80;
    server_name api.votre-domaine.com;

    location / {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}

# Dashboard Admin
server {
    listen 80;
    server_name dashboard.votre-domaine.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

## 🔒 SSL/HTTPS avec Let's Encrypt

```bash
# Installer Certbot
sudo apt-get update
sudo apt-get install certbot python3-certbot-nginx

# Obtenir un certificat
sudo certbot --nginx -d api.votre-domaine.com -d dashboard.votre-domaine.com

# Renouvellement automatique
sudo certbot renew --dry-run
```

## 🗄️ Migration vers PostgreSQL

### Installation PostgreSQL

```bash
sudo apt-get install postgresql postgresql-contrib
```

### Configuration

1. Créer la base de données :
```bash
sudo -u postgres psql
CREATE DATABASE auxivie;
CREATE USER auxivie_user WITH PASSWORD 'votre-mot-de-passe';
GRANT ALL PRIVILEGES ON DATABASE auxivie TO auxivie_user;
\q
```

2. Installer le driver PostgreSQL :
```bash
cd backend
npm install pg
```

3. Migrer les données :
```bash
node scripts/migrate-to-postgres.js
```

4. Mettre à jour `.env.production` :
```env
PG_HOST=localhost
PG_PORT=5432
PG_DATABASE=auxivie
PG_USER=auxivie_user
PG_PASSWORD=votre-mot-de-passe
```

## 💾 Backups

### Backup automatique (cron)

Ajoutez dans votre crontab :
```bash
crontab -e
```

Ajoutez cette ligne pour un backup quotidien à 2h du matin :
```
0 2 * * * cd /chemin/vers/backend && node scripts/backup-db.js
```

## 📊 Monitoring

### PM2 Monitoring

```bash
pm2 monit
pm2 logs
```

### Health Check

Le backend expose un endpoint de santé :
```
GET /api/health
```

## 🔍 Vérification du déploiement

1. **Backend** : `curl https://api.votre-domaine.com/api/health`
2. **Dashboard** : Ouvrir `https://dashboard.votre-domaine.com`
3. **Application** : Tester la connexion depuis l'app mobile

## 🚨 Sécurité

- ✅ Utilisez des secrets forts (JWT_SECRET)
- ✅ Activez HTTPS
- ✅ Configurez CORS correctement
- ✅ Limitez les accès au serveur (firewall)
- ✅ Mettez à jour régulièrement les dépendances
- ✅ Surveillez les logs

## 📞 Support

En cas de problème :
1. Vérifiez les logs : `pm2 logs` ou `docker-compose logs`
2. Vérifiez les variables d'environnement
3. Vérifiez la connectivité réseau
4. Consultez la documentation dans `DEPLOYMENT_CHECKLIST.md`

