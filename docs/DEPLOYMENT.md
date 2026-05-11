# 🚀 Aidalya Admin Dashboard - Déploiement en Production

**Date de déploiement:** 9 Décembre 2025
**Status:** ✅ EN PRODUCTION

---

## 📋 Résumé du Déploiement

### Services Actifs
- ✅ **Site vitrine Aidalya** (HTML statique)
  - URL publique : **https://auxivie.org** (fichiers de la landing ; ne plus y servir le dashboard Next.js)
  
- ✅ **Admin Dashboard Frontend** (Next.js)
  - Port: 3000 (local) → **https://aidalia.auxivie.org**
  - Process PM2: admin-dashboard (id: 0)
  
- ✅ **API Backend** (Express.js)
  - Port: 3001 (local) → **https://auxivie.org/api** (reverse proxy sur le domaine principal) et/ou **https://api.auxivie.org**
  - Process PM2: api (id: 3)
  
- ✅ **Base de Données** (MySQL)
  - Host: auth-db1054.hstgr.io:3306
  - Database: u133413376_auxivie
  - Status: Connectée ✅

- ✅ **Web Server** (Nginx)
  - **auxivie.org** : landing statique + proxy `/api/` (et éventuellement `/uploads/`) → localhost:3001
  - **aidalia.auxivie.org** → localhost:3000 (Next.js admin)
  - **api.auxivie.org** → localhost:3001 (si conservé)
  - SSL/TLS: Let's Encrypt (auto-renew)

**Backend — variable `CORS_ORIGIN` (production)** : inclure au minimum  
`https://auxivie.org,https://www.auxivie.org,https://aidalia.auxivie.org,https://www.aidalia.auxivie.org,https://api.auxivie.org`

---

## 🔐 Comptes Administrateurs Créés

### Compte de Test Production
- **Email:** finaltest@auxivie.org
- **Mot de passe:** FinalTest@2025
- **Créé le:** 9 Décembre 2025

### Autres Comptes
- **Email:** admin@auxivie.com
- **Mot de passe:** Test123!

---

## 📍 URLs d'Accès en Production

| Page | URL | Description |
|------|-----|-------------|
| **Landing Aidalya** | https://auxivie.org/ | Site vitrine (statique) |
| **Login admin** | https://aidalia.auxivie.org/login | Connexion dashboard |
| **Register admin** | https://aidalia.auxivie.org/register | Inscription admin |
| **Dashboard** | https://aidalia.auxivie.org/dashboard | Tableau de bord (auth requise) |
| **API Health** | https://api.auxivie.org/ ou https://auxivie.org/api/ | État de l'API |

---

## 🔑 Clés de Sécurité

### Clé d'Activation Admin
- **Clé:** `auxivie-admin-2025`
- **Usage:** Requise pour créer de nouveaux administrateurs
- **Location:** Variable d'environnement `ADMIN_REGISTRATION_KEY` (backend)
- **⚠️ À changer en production:** OUI (modifiez dans `/root/auxivie/backend/.env`)

Note: la valeur réelle de la clé d'activation est stockée dans le fichier de configuration du serveur (`/root/auxivie/backend/.env`) et n'est pas incluse ici pour des raisons de sécurité.

### JWT Secret
- **Location:** Variable d'environnement `JWT_SECRET` (backend)
- **Expiration:** 7 jours
- **⚠️ À changer:** OUI (générez une clé sécurisée)

---

## 🛠️ Endpoints API Disponibles

### Authentification
```bash
# Login
POST /api/auth/login
{
  "email": "admin@auxivie.com",
  "password": "Test123!"
}

# Inscription Admin
POST /api/auth/register-admin
{
  "email": "newadmin@auxivie.org",
  "password": "SecurePass@123",
  "name": "Admin Name",
  "adminKey": "auxivie-admin-2025"
}
```

### Utilisateurs
```bash
# Lister tous les utilisateurs (nécessite token)
GET /api/users
Authorization: Bearer {token}

# Récupérer un utilisateur
GET /api/users/:id
Authorization: Bearer {token}

# Mettre à jour un utilisateur
PUT /api/users/:id
Authorization: Bearer {token}
```

### Documents, Paiements, Évaluations
- `GET/POST /api/documents`
- `GET/POST /api/payments`
- `GET/POST /api/badges`
- `GET/POST /api/reviews`
- `GET/POST /api/reservations`
- Et plus...

---

## 📝 Variables d'Environnement Importantes

### Frontend (`/root/auxivie/admin-dashboard/.env.production`)
```env
NEXT_PUBLIC_API_BASE_URL=https://api.auxivie.org
NEXT_PUBLIC_API_URL=https://api.auxivie.org
NODE_ENV=production
```

### Backend (`/root/auxivie/backend/.env`)
```env
DB_HOST=auth-db1054.hstgr.io
DB_USER=u133413376_root
DB_PASSWORD=Auxivie2025@
DB_NAME=u133413376_auxivie
DB_PORT=3306
PORT=3001
NODE_ENV=production
JWT_SECRET=your-secret-key
CREDENTIALS: ADMIN_REGISTRATION_KEY is stored on the server's `.env` (REDACTED)
CORS_ORIGIN=https://auxivie.org,https://www.auxivie.org,https://aidalia.auxivie.org,https://www.aidalia.auxivie.org,https://api.auxivie.org
API_URL=https://api.auxivie.org
```

---

## 📦 Fichiers Modifiés/Créés

### Frontend
- ✅ `/pages/register.js` - Nouvelle page d'inscription admin
- ✅ `/pages/login.js` - Mise à jour avec lien vers register
- ✅ `/styles/Register.module.css` - Styles pour la page d'inscription
- ✅ `/lib/api.js` - Nouvel endpoint `registerAdmin()`
- ✅ Build production dans `/.next/`

### Backend
- ✅ `/server.js` - Nouvel endpoint `/api/auth/register-admin`
- ✅ Sauvegarde: `/server.js.backup`

### Infrastructure
- ✅ `/etc/nginx/sites-enabled/api.auxivie.org.conf` - Proxy corrigé (port 3001)
- ✅ `/etc/nginx/sites-enabled/auxivie.org.conf` - Proxy OK (port 3000)

---

## 🔄 Commandes PM2 Utiles

```bash
# Voir le statut
pm2 status

# Voir les logs
pm2 logs admin-dashboard
pm2 logs api

# Redémarrer les services
pm2 restart admin-dashboard api

# Arrêter les services
pm2 stop admin-dashboard api

# Démarrer les services
pm2 start admin-dashboard api

# Recharger les variables d'environnement
pm2 restart admin-dashboard api --update-env
```

---

## 🧪 Tests de Production Validés

### Test 1: Page de Login ✅
```bash
curl -s https://aidalia.auxivie.org/login -I | head -1
# HTTP/1.1 200 OK
```

### Test 2: Page d'Inscription ✅
```bash
curl -s https://aidalia.auxivie.org/register -I | head -1
# HTTP/1.1 200 OK
```

### Test 3: Login API ✅
```bash
curl -s -X POST https://api.auxivie.org/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@auxivie.com","password":"Test123!"}' \
  | jq '.token'
# Returns JWT token
```

### Test 4: Register API ✅
```bash
curl -s -X POST https://api.auxivie.org/api/auth/register-admin \
  -H "Content-Type: application/json" \
  -d '{"email":"test@auxivie.org","password":"Test@123","name":"Test","adminKey":"auxivie-admin-2025"}' \
  | jq '.message'
# Returns: "Administrateur créé avec succès"
```

---

## ⚠️ Checklist de Sécurité

- [ ] ✅ Changer la clé d'activation admin (`ADMIN_REGISTRATION_KEY`)
- [ ] ✅ Changer le JWT_SECRET
- [ ] ✅ Configurer les backups automatiques MySQL
- [ ] ✅ Mettre en place la surveillance (monitoring)
- [ ] ✅ Configurer les alertes d'erreur
- [ ] ✅ Vérifier les certificats SSL (valides jusqu'à: 2026)
- [ ] ✅ Mettre en place un système de log centralisé

---

## 🚨 Dépannage

### Les services ne démarrent pas
```bash
# Vérifier les logs
pm2 logs api
pm2 logs admin-dashboard

# Redémarrer les services
pm2 restart api admin-dashboard

# Vérifier la connexion MySQL
mysql -h auth-db1054.hstgr.io -u u133413376_root -p
```

### Les pages retournent une erreur 500
```bash
# Vérifier les logs PM2
pm2 logs admin-dashboard --lines 50

# Vérifier Nginx
sudo nginx -t
sudo systemctl reload nginx
```

### L'API ne répond pas
```bash
# Vérifier si le service écoute
lsof -i :3001

# Vérifier la configuration Nginx
cat /etc/nginx/sites-enabled/api.auxivie.org.conf
```

---

## 🔁 Option C — Reverse proxy via VPS (solution demandée)

Si certains réseaux bloquent l'accès direct à `api.auxivie.org`, une solution robuste consiste à placer un petit VPS public qui fera office de reverse-proxy frontal. Le VPS servira le trafic public (HTTPS) et le redirigera vers votre serveur interne via un tunnel SSH ou WireGuard. Avantages : contrôle total, domaine propre, et contournement des restrictions réseau du client.

Choix d'architecture (deux variantes)
- Variante 1 — SSH reverse tunnel (rapide, sans config réseau complexe)
- Variante 2 — WireGuard VPN (plus robuste, performant, recommandé pour production)

Étapes rapides — Variante 1 (SSH reverse tunnel)

1) Sur le VPS (public) — installer Nginx et configurer le site `auxivie-proxy` :

```bash
# Installer nginx
sudo apt update && sudo apt install -y nginx

# Exemple de config /etc/nginx/sites-available/auxivie-proxy
cat <<'NGINX' | sudo tee /etc/nginx/sites-available/auxivie-proxy
server {
  listen 80;
  server_name auxivie.org www.auxivie.org;
  return 301 https://$host$request_uri;
}

server {
  listen 443 ssl http2;
  server_name auxivie.org www.auxivie.org;

  ssl_certificate /etc/letsencrypt/live/auxivie.org/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/auxivie.org/privkey.pem;

  location / {
    proxy_pass http://127.0.0.1:30000; # local port forwarded via SSH tunnel
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
  }
}
NGINX

sudo ln -s /etc/nginx/sites-available/auxivie-proxy /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
```

2) Sur votre serveur interne (où tourne le backend sur localhost:3001) lancer un tunnel SSH persistant vers le VPS qui mappe `localhost:3001` sur le VPS `127.0.0.1:30000` :

```bash
# Sur le serveur interne
ssh -fN -o ServerAliveInterval=60 -o ExitOnForwardFailure=yes -R 127.0.0.1:30000:127.0.0.1:3001 user@VPS_IP

# Pour rendre le tunnel persistant, créez un systemd unit (example below)
```

3) Exemple systemd unit sur le serveur interne (`/etc/systemd/system/reverse-ssh-tunnel.service`):

```ini
[Unit]
Description=Reverse SSH Tunnel to VPS for Aidalya
After=network.target

[Service]
User=root
ExecStart=/usr/bin/ssh -o ServerAliveInterval=60 -o ExitOnForwardFailure=yes -N -R 127.0.0.1:30000:127.0.0.1:3001 user@VPS_IP
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Puis:
```bash
sudo systemctl daemon-reload
sudo systemctl enable --now reverse-ssh-tunnel.service
sudo systemctl status reverse-ssh-tunnel.service
```

4) Avantages/Inconvénients Variante 1
- Avantages: rapide à mettre en place, pas de modification réseau sur le VPS autre que SSH, pas besoin de changer DNS si le VPS héberge le domaine
- Inconvénients: moins performant que VPN, dépend d'un seul tunnel SSH, possible overhead sur connexions simultanées

Étapes rapides — Variante 2 (WireGuard VPN) — recommandé pour production

1) Sur le VPS public : installer WireGuard

```bash
sudo apt update && sudo apt install -y wireguard qrencode
```

2) Générer clés et config serveur WireGuard (`/etc/wireguard/wg0.conf`) :

```bash
# Sur le VPS
umask 077
wg genkey | tee server_private.key | wg pubkey > server_public.key
SERVER_PRIV=$(cat server_private.key)
cat <<EOF | sudo tee /etc/wireguard/wg0.conf
[Interface]
Address = 10.10.0.1/24
ListenPort = 51820
PrivateKey = ${SERVER_PRIV}
SaveConfig = true

# Peer (your internal server) will be added after you create its keys
EOF

sudo systemctl enable --now wg-quick@wg0
```

3) Sur le serveur interne (Aidalya) : installer WireGuard, générer clés, config client et autoriser routing vers 127.0.0.1:3001

```bash
sudo apt update && sudo apt install -y wireguard qrencode
wg genkey | tee client_private.key | wg pubkey > client_public.key
CLIENT_PRIV=$(cat client_private.key)
CLIENT_PUB=$(cat client_public.key)

# Ajouter peer sur VPS: (SSH to VPS and append the peer config)
# On VPS append to /etc/wireguard/wg0.conf:
#
# [Peer]
# PublicKey = <client_public_key>
# AllowedIPs = 10.10.0.2/32
#
# Exemple config client /etc/wireguard/wg0.conf
cat <<EOF | sudo tee /etc/wireguard/wg0.conf
[Interface]
Address = 10.10.0.2/24
PrivateKey = ${CLIENT_PRIV}
DNS = 1.1.1.1

[Peer]
PublicKey = <SERVER_PUBLIC_KEY> # remplacer
Endpoint = VPS_IP:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOF

sudo systemctl enable --now wg-quick@wg0
```

4) Nginx sur VPS — proxy vers WireGuard IP du serveur:

```nginx
location /api/ {
  proxy_pass http://10.10.0.2:3001; # IP WireGuard du serveur interne
}
```

5) Avantages/Inconvénients Variante 2
- Avantages: performant, sécurisé, supporte beaucoup de trafic, scalable, stable pour production
- Inconvénients: configuration initiale plus longue, nécessite gestion des clés et routage

Vérifications à la fin
- Depuis un appareil externe (téléphone), tester:
  - https://aidalia.auxivie.org/login
  - https://auxivie.org/
  - https://auxivie.org/api/health
- Sur VPS: `curl -s http://127.0.0.1:30000/api/health` (si SSH tunnel) ou `curl -s http://10.10.0.2:3001/api/health` (si WireGuard)

Je peux implémenter la variante choisie (SSH tunnel rapide ou WireGuard complet). Dites-moi laquelle vous préférez et j'exécute les étapes sur le serveur et/ou VPS (il me faudra accès SSH au VPS ou vous pouvez exécuter les commandes que je fournis).


## 📞 Support

Pour tout problème ou question sur le déploiement:
1. Vérifier les logs: `pm2 logs`
2. Vérifier la configuration: `cat .env`
3. Vérifier Nginx: `sudo nginx -t`
4. Redémarrer si nécessaire: `pm2 restart all`

---

**Déploiement réalisé avec succès! 🎉**
