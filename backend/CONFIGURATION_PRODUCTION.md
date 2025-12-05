# ⚙️ Configuration de Production

## 📋 Configuration Complète du Fichier .env

Créez un fichier `.env` dans le dossier `backend/` avec cette configuration exacte :

```env
PORT=3001
NODE_ENV=production

DB_HOST=auth-db1232.hstgr.io
DB_USER=u133413376_root
DB_PASSWORD=Auxivie2025
DB_NAME=u133413376_auxivie
DB_PORT=3306

JWT_SECRET=E9rT7yU6iO3pL8qW1aS2dF4gH5jK0lM
CORS_ORIGIN=https://www.auxivie.org
```

---

## 🔍 Vérification de la Configuration

### Sur le VPS, vérifiez le fichier .env :

```bash
cd ~/backend/backend
cat .env
```

### Vérifiez que toutes les variables sont présentes :

```bash
cat .env | grep -E "^(PORT|NODE_ENV|DB_HOST|DB_USER|DB_PASSWORD|DB_NAME|DB_PORT|JWT_SECRET|CORS_ORIGIN)="
```

Vous devriez voir :
- `PORT=3001`
- `NODE_ENV=production`
- `DB_HOST=auth-db1232.hstgr.io`
- `DB_USER=u133413376_root`
- `DB_PASSWORD=Auxivie2025`
- `DB_NAME=u133413376_auxivie`
- `DB_PORT=3306`
- `JWT_SECRET=E9rT7yU6iO3pL8qW1aS2dF4gH5jK0lM`
- `CORS_ORIGIN=https://www.auxivie.org`

---

## 🧪 Test de Connexion

### Test 1 : Vérifier les variables d'environnement

```bash
cd ~/backend/backend
node scripts/debug-mysql-connection.js
```

### Test 2 : Test de connexion MySQL

```bash
node scripts/test-mysql-connection.js
```

### Test 3 : Démarrer le serveur

```bash
npm start
```

Vous devriez voir :
```
✅ Connexion MySQL établie
✅ Base de données MySQL initialisée
🚀 Serveur API démarré sur http://localhost:3001
```

---

## ⚠️ Points Importants

1. **DB_HOST** : Utilise `auth-db1232.hstgr.io` (serveur MySQL distant Hostinger), **PAS** `localhost`
2. **JWT_SECRET** : Doit être une clé secrète aléatoire et longue
3. **CORS_ORIGIN** : Doit correspondre exactement à votre domaine de production
4. **Pas d'espaces** : Assurez-vous qu'il n'y a pas d'espaces autour du `=` dans le `.env`

---

## 🔧 Recréer le Fichier .env Proprement

Si vous devez recréer le fichier `.env` :

```bash
cd ~/backend/backend

# Sauvegarder l'ancien
cp .env .env.backup

# Créer le nouveau
cat > .env << 'EOF'
PORT=3001
NODE_ENV=production

DB_HOST=auth-db1232.hstgr.io
DB_USER=u133413376_root
DB_PASSWORD=Auxivie2025
DB_NAME=u133413376_auxivie
DB_PORT=3306

JWT_SECRET=E9rT7yU6iO3pL8qW1aS2dF4gH5jK0lM
CORS_ORIGIN=https://www.auxivie.org
EOF

# Vérifier
cat .env
```

---

## 📝 Notes

- Le fichier `.env` ne doit **JAMAIS** être commité sur GitHub (déjà dans `.gitignore`)
- Utilisez cette configuration uniquement en **production**
- Pour le développement local, utilisez une configuration différente avec `DB_HOST=localhost` ou `127.0.0.1`

