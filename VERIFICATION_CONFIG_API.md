# 🔍 Vérification Configuration API

## 📋 Configuration Actuelle

### Dashboard (admin-dashboard/lib/api.js)
```javascript
const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001';
```

**URL de login** : `${API_BASE_URL}/api/auth/login`

### Backend CORS (backend/server.js)
```javascript
origin: process.env.CORS_ORIGIN 
  ? process.env.CORS_ORIGIN.split(',').map(origin => origin.trim())
  : process.env.NODE_ENV === 'production'
    ? ['https://www.auxivie.org', 'https://auxivie.org', 'https://api.auxivie.org']
    : '*'
```

✅ **CORS accepte déjà** : `https://www.auxivie.org` et `https://auxivie.org`

### Backend Port
```javascript
const PORT = process.env.PORT || 3001;
```

✅ **Port** : `3001`

---

## 🧪 Vérification dans le Navigateur

### 1. Ouvrir le Dashboard

1. Allez sur `https://www.auxivie.org` ou `https://auxivie.org`
2. Ouvrez la **console du navigateur** (F12)
3. Allez dans l'onglet **"Network"** ou **"Réseau"**

### 2. Tenter une Connexion

1. Entrez les identifiants :
   - Email : `admin@auxivie.com`
   - Password : `admin123`
2. Cliquez sur **"Se connecter"**

### 3. Vérifier la Requête

Dans l'onglet Network, cherchez la requête vers `/api/auth/login` :

**URL attendue** : `https://api.auxivie.org/api/auth/login`

**Méthode** : `POST`

**Status** :
- ✅ `200` : Connexion réussie
- ❌ `401` : Email/mot de passe incorrect
- ❌ `403` : Accès réservé aux administrateurs
- ❌ `CORS error` : Problème de CORS
- ❌ `Failed to fetch` : API inaccessible

---

## 🔧 Vérifications à Faire

### Sur le VPS (Backend)

```bash
# 1. Vérifier que le serveur écoute sur le port 3001
cd ~/backend/backend
cat .env | grep PORT

# 2. Vérifier CORS_ORIGIN
cat .env | grep CORS_ORIGIN

# 3. Vérifier que le serveur tourne
pm2 status
# ou
curl http://localhost:3001/api/health
```

### Sur Hostinger (Dashboard)

```bash
# 1. Vérifier .env.production
cd ~/domains/auxivie.org/public_html/admin_dashboard
cat .env.production

# Devrait contenir :
# NEXT_PUBLIC_API_URL=https://api.auxivie.org

# 2. Vérifier que le Dashboard est rebuild
ls -la .next/
```

---

## 🚨 Erreurs Courantes

### Erreur CORS

**Symptôme** : `Access to fetch at 'https://api.auxivie.org/api/auth/login' from origin 'https://www.auxivie.org' has been blocked by CORS policy`

**Solution** : Vérifier que `CORS_ORIGIN` dans `.env` du backend contient :
```
CORS_ORIGIN=https://www.auxivie.org,https://auxivie.org
```

### Erreur "Failed to fetch"

**Symptôme** : `Failed to fetch` ou `NetworkError`

**Solutions** :
1. Vérifier que le backend tourne : `pm2 status`
2. Vérifier que le port 3001 est ouvert
3. Vérifier que l'URL `https://api.auxivie.org` pointe vers le VPS
4. Tester directement : `curl https://api.auxivie.org/api/health`

### Erreur 401

**Symptôme** : `{"message":"Email ou mot de passe incorrect"}`

**Solution** : Créer/mettre à jour l'admin :
```bash
cd ~/backend/backend
node scripts/create-admin-mysql.js
```

### Erreur 403

**Symptôme** : `{"message":"Accès réservé aux administrateurs"}`

**Solution** : Vérifier que `userType = 'admin'` :
```bash
cd ~/backend/backend
node scripts/test-admin-login.js
```

---

## 📋 Checklist de Vérification

- [ ] Dashboard accessible sur `https://www.auxivie.org`
- [ ] `.env.production` contient `NEXT_PUBLIC_API_URL=https://api.auxivie.org`
- [ ] Dashboard rebuild (`npm run build`)
- [ ] Backend accessible sur `https://api.auxivie.org` ou `http://178.16.131.24:3001`
- [ ] Backend écoute sur port 3001
- [ ] CORS_ORIGIN contient `https://www.auxivie.org` et `https://auxivie.org`
- [ ] Admin existe dans la base de données
- [ ] Test de connexion dans le navigateur (Network tab)

---

**Pour avancer, vérifiez dans la console du navigateur (F12 → Network) quelle URL est utilisée pour `/api/auth/login` et quelle erreur apparaît !**

