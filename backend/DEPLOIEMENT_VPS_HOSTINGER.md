# 🚀 Guide de Déploiement Backend sur VPS Hostinger

## 📍 Informations VPS

- **Adresse SSH** : `ssh apiuser@178.16.131.24`
- **Utilisateur** : `apiuser`
- **IP** : `178.16.131.24`

---

## 🔧 Étape 1 : Se Connecter au VPS

### Sur votre Mac

Ouvrez le Terminal et exécutez :

```bash
ssh apiuser@178.16.131.24
```

**Note** : Vous devrez entrer le mot de passe SSH (ou utiliser une clé SSH si configurée).

---

## 📁 Étape 2 : Structure des Dossiers sur le VPS

Une fois connecté, créez la structure suivante :

```bash
# Créer le dossier backend
mkdir -p ~/backend
cd ~/backend

# Créer les dossiers nécessaires
mkdir -p data
mkdir -p uploads/documents
mkdir -p uploads/photos
mkdir -p scripts
```

---

## 📦 Étape 3 : Installer Node.js et npm

Vérifiez si Node.js est installé :

```bash
node --version
npm --version
```

Si Node.js n'est pas installé, installez-le :

```bash
# Sur Ubuntu/Debian
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Vérifier l'installation
node --version
npm --version
```

---

## 📤 Étape 4 : Uploader les Fichiers

### Option A : Via SCP (depuis votre Mac)

Depuis votre Mac, dans un nouveau terminal :

```bash
# Naviguer vers le dossier du projet
cd "/Users/david/Christelle Projet/backend"

# Uploader les fichiers essentiels
scp server.js apiuser@178.16.131.24:~/backend/
scp package.json apiuser@178.16.131.24:~/backend/
scp package-lock.json apiuser@178.16.131.24:~/backend/
scp db.js apiuser@178.16.131.24:~/backend/

# Uploader le dossier scripts
scp -r scripts apiuser@178.16.131.24:~/backend/
```

### Option B : Via Git (Recommandé)

Sur le VPS :

```bash
cd ~/backend

# Cloner le repository (si vous avez accès)
git clone https://github.com/Davidexauce/auxivie.git temp
cp -r temp/backend/* .
rm -rf temp

# OU télécharger depuis GitHub directement
```

### Option C : Via FileZilla (FTP/SFTP)

1. Utilisez FileZilla ou un autre client SFTP
2. Connectez-vous avec :
   - **Hôte** : `sftp://178.16.131.24`
   - **Utilisateur** : `apiuser`
   - **Mot de passe** : (votre mot de passe SSH)
3. Naviguez vers `~/backend/`
4. Uploader les fichiers

---

## ⚙️ Étape 5 : Créer le Fichier .env

Sur le VPS, dans `~/backend/` :

```bash
nano .env
```

Collez ce contenu (remplacez par vos vraies valeurs) :

```env
# Port du serveur
PORT=3001

# Environnement
NODE_ENV=production

# Configuration MySQL
DB_HOST=localhost
DB_USER=votre_utilisateur_mysql
DB_PASSWORD=votre_mot_de_passe_mysql
DB_NAME=u133413376_auxivie
DB_PORT=3306

# JWT Secret (changez par une clé aléatoire)
JWT_SECRET=changez_cette_cle_par_une_cle_aleatoire_secrete_et_longue

# CORS
CORS_ORIGIN=https://www.auxivie.org

# Stripe (optionnel)
STRIPE_SECRET_KEY=sk_test_votre_cle_stripe
```

**Sauvegarder** : `Ctrl+X`, puis `Y`, puis `Entrée`

---

## 📦 Étape 6 : Installer les Dépendances

Sur le VPS :

```bash
cd ~/backend
npm install --production
```

Cela installera toutes les dépendances, y compris `mysql2`.

---

## 🗄️ Étape 7 : Configurer MySQL

### Vérifier que MySQL est installé

```bash
mysql --version
```

### Se connecter à MySQL

```bash
mysql -u root -p
```

### Créer la base de données (si nécessaire)

```sql
CREATE DATABASE IF NOT EXISTS u133413376_auxivie CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### Créer un utilisateur (si nécessaire)

```sql
CREATE USER 'votre_utilisateur'@'localhost' IDENTIFIED BY 'votre_mot_de_passe';
GRANT ALL PRIVILEGES ON u133413376_auxivie.* TO 'votre_utilisateur'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### Importer la base de données

```bash
# Si vous avez le fichier SQL
mysql -u votre_utilisateur -p u133413376_auxivie < auxivie-mysql.sql
```

---

## 🚀 Étape 8 : Démarrer le Backend

### Option A : Avec PM2 (Recommandé)

Installer PM2 :

```bash
npm install -g pm2
```

Démarrer l'application :

```bash
cd ~/backend
pm2 start server.js --name auxivie-api
pm2 save
pm2 startup
```

### Option B : Avec systemd

Créer un service systemd :

```bash
sudo nano /etc/systemd/system/auxivie-api.service
```

Contenu :

```ini
[Unit]
Description=Auxivie API Backend
After=network.target

[Service]
Type=simple
User=apiuser
WorkingDirectory=/home/apiuser/backend
Environment=NODE_ENV=production
ExecStart=/usr/bin/node server.js
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Activer et démarrer :

```bash
sudo systemctl daemon-reload
sudo systemctl enable auxivie-api
sudo systemctl start auxivie-api
sudo systemctl status auxivie-api
```

### Option C : En arrière-plan simple

```bash
cd ~/backend
nohup node server.js > app.log 2>&1 &
```

---

## 🔍 Étape 9 : Vérifier que ça fonctionne

### Vérifier les logs

```bash
# Avec PM2
pm2 logs auxivie-api

# Avec systemd
sudo journalctl -u auxivie-api -f

# Avec nohup
tail -f ~/backend/app.log
```

Vous devriez voir :
```
✅ Connexion MySQL établie
✅ Base de données MySQL initialisée
🚀 Serveur API démarré sur http://localhost:3001
✅ Connexion MySQL établie
```

### Tester l'API

```bash
curl http://localhost:3001/api/health
```

---

## 🌐 Étape 10 : Configurer le Domaine API

### Option A : Nginx (Recommandé)

Installer Nginx :

```bash
sudo apt update
sudo apt install nginx
```

Créer la configuration :

```bash
sudo nano /etc/nginx/sites-available/api.auxivie.org
```

Contenu :

```nginx
server {
    listen 80;
    server_name api.auxivie.org;

    location / {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Activer le site :

```bash
sudo ln -s /etc/nginx/sites-available/api.auxivie.org /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### Option B : Apache

Si vous utilisez Apache, créez un VirtualHost similaire.

---

## 🔒 Étape 11 : Configurer SSL (HTTPS)

### Avec Let's Encrypt

```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d api.auxivie.org
```

---

## ✅ Checklist de Vérification

- [ ] Connecté au VPS via SSH
- [ ] Node.js installé
- [ ] Fichiers backend uploadés
- [ ] Fichier `.env` créé avec les bonnes valeurs
- [ ] Dépendances installées (`npm install`)
- [ ] MySQL configuré et base importée
- [ ] Backend démarré (PM2, systemd, ou nohup)
- [ ] Logs vérifiés (pas d'erreur)
- [ ] API testée (`curl http://localhost:3001/api/health`)
- [ ] Nginx/Apache configuré
- [ ] Domaine `api.auxivie.org` pointant vers le VPS
- [ ] SSL configuré (HTTPS)

---

## 🆘 Dépannage

### Le backend ne démarre pas

```bash
# Vérifier les logs
pm2 logs auxivie-api
# ou
sudo journalctl -u auxivie-api -n 50

# Vérifier que le port n'est pas utilisé
sudo netstat -tulpn | grep 3001

# Vérifier les permissions
ls -la ~/backend
```

### Erreur de connexion MySQL

```bash
# Tester la connexion MySQL
mysql -u votre_utilisateur -p -h localhost u133413376_auxivie

# Vérifier que MySQL écoute
sudo netstat -tulpn | grep 3306
```

### Le domaine ne fonctionne pas

```bash
# Vérifier la configuration Nginx
sudo nginx -t

# Vérifier les logs Nginx
sudo tail -f /var/log/nginx/error.log
```

---

**Une fois terminé, votre API sera accessible sur `https://api.auxivie.org` ! 🎉**

