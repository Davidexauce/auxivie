# 🔐 Guide de Connexion au VPS Hostinger

## 📍 Informations de Connexion

- **Adresse SSH** : `ssh apiuser@178.16.131.24`
- **Utilisateur** : `apiuser`
- **IP** : `178.16.131.24`

---

## 🚀 Connexion Rapide

### Sur votre Mac

Ouvrez le Terminal et exécutez :

```bash
ssh apiuser@178.16.131.24
```

Vous serez invité à entrer le mot de passe SSH.

---

## 📋 Commandes Essentielles

### Une fois connecté au VPS

```bash
# Voir où vous êtes
pwd

# Aller dans le dossier home
cd ~

# Créer le dossier backend
mkdir -p ~/backend
cd ~/backend

# Vérifier Node.js
node --version
npm --version

# Voir les fichiers
ls -la
```

---

## 📤 Upload des Fichiers depuis votre Mac

### Option 1 : Via SCP (Recommandé)

Dans un **nouveau terminal** sur votre Mac (gardez la connexion SSH ouverte dans un autre) :

```bash
cd "/Users/david/Christelle Projet/backend"

# Uploader les fichiers un par un
scp server.js apiuser@178.16.131.24:~/backend/
scp package.json apiuser@178.16.131.24:~/backend/
scp package-lock.json apiuser@178.16.131.24:~/backend/
scp db.js apiuser@178.16.131.24:~/backend/

# Uploader le dossier scripts
scp -r scripts apiuser@178.16.131.24:~/backend/
```

### Option 2 : Utiliser le Script de Déploiement

Sur votre Mac :

```bash
cd "/Users/david/Christelle Projet/backend"
./scripts/deploy-to-vps.sh
```

---

## ⚙️ Configuration sur le VPS

### 1. Créer le fichier .env

```bash
cd ~/backend
nano .env
```

Collez et modifiez :

```env
PORT=3001
NODE_ENV=production
DB_HOST=localhost
DB_USER=votre_utilisateur_mysql
DB_PASSWORD=votre_mot_de_passe_mysql
DB_NAME=u133413376_auxivie
DB_PORT=3306
JWT_SECRET=votre_cle_secrete_aleatoire
CORS_ORIGIN=https://www.auxivie.org
```

**Sauvegarder** : `Ctrl+X`, `Y`, `Entrée`

### 2. Exécuter le Script de Configuration

```bash
cd ~/backend
bash scripts/setup-vps.sh
```

OU manuellement :

```bash
# Créer les dossiers
mkdir -p data uploads/documents uploads/photos

# Installer les dépendances
npm install --production

# Installer PM2
npm install -g pm2
```

### 3. Démarrer le Backend

```bash
cd ~/backend
pm2 start server.js --name auxivie-api
pm2 save
pm2 startup
```

### 4. Vérifier les Logs

```bash
pm2 logs auxivie-api
```

Vous devriez voir :
```
✅ Connexion MySQL établie
🚀 Serveur API démarré sur http://localhost:3001
```

---

## 🔍 Vérification

### Tester l'API sur le VPS

```bash
curl http://localhost:3001/api/health
```

### Tester depuis l'extérieur

```bash
curl http://178.16.131.24:3001/api/health
```

---

## 📝 Commandes PM2 Utiles

```bash
# Voir les processus
pm2 list

# Voir les logs
pm2 logs auxivie-api

# Redémarrer
pm2 restart auxivie-api

# Arrêter
pm2 stop auxivie-api

# Supprimer
pm2 delete auxivie-api
```

---

## 🌐 Configuration du Domaine

Une fois le backend fonctionnel, configurez `api.auxivie.org` pour pointer vers `178.16.131.24`.

---

**Besoin d'aide ? Consultez `backend/DEPLOIEMENT_VPS_HOSTINGER.md` pour plus de détails.**

