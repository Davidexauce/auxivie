# 🔧 Guide : Résoudre le Problème de Connexion Admin

## ❌ Problème

Impossible de se connecter au Dashboard avec :
- Email : `admin@auxivie.com`
- Password : `admin123`

---

## 🔍 Diagnostic

### Sur le VPS, exécutez :

```bash
cd ~/backend/backend

# Télécharger les scripts mis à jour
git pull origin master

# Tester l'admin
node scripts/test-admin-login.js
```

Ce script va vérifier :
1. ✅ Si l'admin existe dans la base de données
2. ✅ Si `userType = 'admin'`
3. ✅ Si le mot de passe est correct
4. ✅ Si la connexion API fonctionne

---

## 🔧 Solution 1 : Créer/Mettre à Jour l'Admin

Si l'admin n'existe pas ou si le mot de passe est incorrect :

```bash
cd ~/backend/backend

# Créer ou mettre à jour l'admin
node scripts/create-admin-mysql.js
```

Ce script va :
- Créer l'admin s'il n'existe pas
- Mettre à jour le mot de passe s'il existe
- S'assurer que `userType = 'admin'` et `categorie = 'Admin'`

---

## 🔧 Solution 2 : Vérifier/Corriger manuellement dans MySQL

Si vous préférez le faire manuellement via phpMyAdmin :

### 1. Vérifier si l'admin existe

```sql
SELECT id, email, userType, categorie FROM users WHERE email = 'admin@auxivie.com';
```

### 2. Si l'admin n'existe pas, le créer

Vous devez d'abord hasher le mot de passe. Utilisez le script Node.js :

```bash
node scripts/create-admin-mysql.js
```

### 3. Si l'admin existe mais `userType` n'est pas 'admin'

```sql
UPDATE users 
SET userType = 'admin', categorie = 'Admin' 
WHERE email = 'admin@auxivie.com';
```

### 4. Si le mot de passe est incorrect

Exécutez le script :

```bash
node scripts/create-admin-mysql.js
```

---

## 🔧 Solution 3 : Vérifier la Route de Login

La route `/api/auth/login` doit :
1. ✅ Accepter les requêtes sans header `x-request-type: mobile`
2. ✅ Vérifier que `userType = 'admin'` pour les requêtes non-mobile
3. ✅ Retourner un token JWT

### Test de la route de login

```bash
# Depuis le VPS
curl -X POST http://localhost:3001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@auxivie.com","password":"admin123"}'
```

**Réponse attendue** :
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "name": "Administrateur",
    "email": "admin@auxivie.com",
    "userType": "admin"
  }
}
```

**Si vous obtenez une erreur 403** :
```json
{"message":"Accès réservé aux administrateurs"}
```

Cela signifie que `userType` n'est pas `'admin'`. Utilisez Solution 2, étape 3.

**Si vous obtenez une erreur 401** :
```json
{"message":"Email ou mot de passe incorrect"}
```

Cela signifie que le mot de passe est incorrect. Utilisez Solution 1.

---

## 🔧 Solution 4 : Vérifier le Dashboard

### Vérifier l'URL de l'API dans le Dashboard

Dans `admin-dashboard/lib/api.js`, vérifiez que :

```javascript
const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001';
```

En production, cela doit être :

```javascript
const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'https://api.auxivie.org';
```

Ou si l'API est sur le même serveur :

```javascript
const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001';
```

### Vérifier les variables d'environnement du Dashboard

Dans `admin-dashboard/.env` ou `admin-dashboard/.env.production` :

```env
NEXT_PUBLIC_API_URL=http://localhost:3001
```

Ou en production :

```env
NEXT_PUBLIC_API_URL=https://api.auxivie.org
```

---

## 📋 Checklist de Vérification

- [ ] Admin existe dans la base de données (`SELECT * FROM users WHERE email = 'admin@auxivie.com'`)
- [ ] `userType = 'admin'` pour l'admin
- [ ] `categorie = 'Admin'` pour l'admin
- [ ] Mot de passe est hashé avec bcrypt (commence par `$2b$`)
- [ ] Test de connexion API réussit (`curl` test)
- [ ] Dashboard pointe vers la bonne URL API
- [ ] Backend est démarré et accessible

---

## 🧪 Tests Complets

### 1. Test de l'admin dans la base

```bash
node scripts/test-admin-login.js
```

### 2. Test de connexion API

```bash
curl -X POST http://localhost:3001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@auxivie.com","password":"admin123"}'
```

### 3. Test depuis le Dashboard

1. Ouvrez `https://www.auxivie.org`
2. Essayez de vous connecter avec `admin@auxivie.com` / `admin123`
3. Vérifiez la console du navigateur (F12) pour les erreurs

---

## 💡 Actions Immédiates

Sur le VPS :

```bash
cd ~/backend/backend

# 1. Télécharger les scripts
git pull origin master

# 2. Créer/mettre à jour l'admin
node scripts/create-admin-mysql.js

# 3. Tester
node scripts/test-admin-login.js

# 4. Tester la connexion API
curl -X POST http://localhost:3001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@auxivie.com","password":"admin123"}'
```

---

**Commencez par exécuter `node scripts/create-admin-mysql.js` pour créer/mettre à jour l'admin !**

