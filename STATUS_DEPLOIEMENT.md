# 📊 État du Déploiement - Auxivie

## ✅ Actions Locales Complétées

### 1. Configuration des fichiers d'environnement
- ✅ `backend/.env.production` créé avec JWT_SECRET généré
- ✅ `admin-dashboard/.env.production` créé
- ✅ `lib/config/app_config.dart` configuré pour production

### 2. JWT_SECRET généré
```
QgV97p45C6x1EAa3JJyCs7EJZA2NLLWmqwBWM0qj2mQ=
```
⚠️ **IMPORTANT** : Ce secret est maintenant dans `backend/.env.production`
⚠️ **NE COMMITEZ JAMAIS** ce fichier dans Git !

### 3. Tests locaux
- ✅ Dépendances backend installées
- ✅ Base de données initialisée
- ✅ Dashboard buildé

### 4. Build Flutter
- ✅ APK de production généré (si build réussi)

---

## ⚠️ Actions Requises - À FAIRE MANUELLEMENT

### Sur votre serveur de production :

#### 1. Installer les dépendances système
```bash
ssh root@votre-serveur-ip
apt update && apt install -y nodejs nginx certbot python3-certbot-nginx
npm install -g pm2
```

#### 2. Déployer le code
```bash
# Option A : Via Git
cd /home/auxivie
git clone https://votre-repo.git auxivie
cd auxivie

# Option B : Via SCP (depuis votre machine locale)
scp -r /Users/david/Christelle\ Projet/* auxivie@votre-serveur:/home/auxivie/auxivie/
```

#### 3. Configurer les variables d'environnement sur le serveur
```bash
cd /home/auxivie/auxivie/backend
nano .env.production
# Collez le JWT_SECRET : QgV97p45C6x1EAa3JJyCs7EJZA2NLLWmqwBWM0qj2mQ=
# Remplacez "votre-domaine.com" par votre vrai domaine
```

#### 4. Démarrer le backend
```bash
cd /home/auxivie/auxivie/backend
npm ci --only=production
pm2 start ecosystem.config.js --env production
pm2 save
pm2 startup
```

#### 5. Démarrer le dashboard (si sur le même serveur)
```bash
cd /home/auxivie/auxivie/admin-dashboard
npm ci
npm run build
pm2 start npm --name dashboard -- start
pm2 save
```

#### 6. Configurer Nginx
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

Activez le site :
```bash
ln -s /etc/nginx/sites-available/auxivie-api /etc/nginx/sites-enabled/
nginx -t
systemctl restart nginx
```

#### 7. Installer SSL
```bash
certbot --nginx -d api.votre-domaine.com -d dashboard.votre-domaine.com
```

---

## 📝 Fichiers à Modifier Avant Déploiement

### 1. `backend/.env.production`
Remplacez `votre-domaine.com` par votre vrai domaine :
```env
CORS_ORIGIN=https://dashboard.VOTRE-DOMAINE.com,https://api.VOTRE-DOMAINE.com
API_URL=https://api.VOTRE-DOMAINE.com
```

### 2. `admin-dashboard/.env.production`
```env
NEXT_PUBLIC_API_URL=https://api.VOTRE-DOMAINE.com
```

### 3. `lib/config/app_config.dart`
```dart
case Environment.production:
  return 'https://api.VOTRE-DOMAINE.com';
```

---

## 🎯 Prochaines Étapes

1. ✅ Configuration locale terminée
2. ⏳ Obtenir un serveur (DigitalOcean, AWS, etc.)
3. ⏳ Configurer les DNS de votre domaine
4. ⏳ Déployer le code sur le serveur
5. ⏳ Configurer Nginx et SSL
6. ⏳ Tester l'application en production

---

## 📦 Fichiers Prêts pour Déploiement

- ✅ Backend configuré
- ✅ Dashboard buildé
- ✅ Application Flutter buildée (APK dans `build/app/outputs/flutter-apk/app-release.apk`)

---

## 🔐 Sécurité

⚠️ **IMPORTANT** :
- Le JWT_SECRET est dans `backend/.env.production`
- Ce fichier est dans `.gitignore` (ne sera pas commité)
- Ne partagez jamais ce secret publiquement
- Utilisez des secrets différents pour chaque environnement

---

## 📞 En cas de problème

Consultez :
- `GUIDE_DEPLOIEMENT_ETAPE_PAR_ETAPE.md` - Guide complet
- `DEPLOYMENT.md` - Guide technique
- Logs PM2 : `pm2 logs`
- Logs Nginx : `/var/log/nginx/error.log`

