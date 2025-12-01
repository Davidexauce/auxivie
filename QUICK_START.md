# ⚡ Démarrage Rapide - Mise en Production

Guide ultra-rapide pour les utilisateurs pressés.

## 🎯 En 5 Minutes

### 1. Préparer localement

```bash
# Créer les fichiers .env
./setup-env.sh

# Générer JWT_SECRET
openssl rand -base64 32
```

### 2. Configurer les .env

**Backend** (`backend/.env.production`) :
```env
JWT_SECRET=VOTRE-SECRET-GÉNÉRÉ
CORS_ORIGIN=https://dashboard.votre-domaine.com
API_URL=https://api.votre-domaine.com
```

**Dashboard** (`admin-dashboard/.env.production`) :
```env
NEXT_PUBLIC_API_URL=https://api.votre-domaine.com
```

**Flutter** (`lib/config/app_config.dart`) :
```dart
static const Environment _currentEnvironment = Environment.production;
// ...
case Environment.production:
  return 'https://api.votre-domaine.com';
```

### 3. Sur le serveur

```bash
# Installer
apt update && apt install -y nodejs nginx certbot
npm install -g pm2

# Déployer le code
cd /home/auxivie/auxivie/backend
npm ci --only=production
pm2 start ecosystem.config.js --env production
pm2 save

# Dashboard (ou utiliser Vercel)
cd ../admin-dashboard
npm ci && npm run build
pm2 start npm --name dashboard -- start
```

### 4. Nginx + SSL

```bash
# Configurer Nginx (voir GUIDE_DEPLOIEMENT_ETAPE_PAR_ETAPE.md)
# Installer SSL
certbot --nginx -d api.votre-domaine.com -d dashboard.votre-domaine.com
```

### 5. Build Flutter

```bash
flutter build apk --release
# ou
flutter build appbundle --release
```

## 📖 Pour plus de détails

Consultez `GUIDE_DEPLOIEMENT_ETAPE_PAR_ETAPE.md` pour le guide complet.

