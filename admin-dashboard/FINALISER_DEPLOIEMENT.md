# ✅ Finaliser le Déploiement du Dashboard

## 📋 Étapes Restantes

Le Dashboard est déployé, il faut maintenant :

1. ✅ Installer les dépendances (`npm install`)
2. ✅ Builder le Dashboard (`npm run build`)
3. ✅ Démarrer le serveur (`npm start` ou PM2)

---

## 🚀 Commandes à Exécuter sur Hostinger

### Via SSH ou Terminal Hostinger

```bash
# 1. Aller dans le dossier admin_dashboard
cd ~/domains/auxivie.org/public_html/admin_dashboard

# 2. Vérifier que .env.production existe et contient la bonne URL
cat .env.production

# Devrait afficher :
# NEXT_PUBLIC_API_URL=https://api.auxivie.org

# 3. Installer les dépendances
npm install

# 4. Builder le Dashboard (IMPORTANT !)
npm run build

# 5. Démarrer le serveur
npm start

# OU configurer avec PM2 (recommandé pour production)
pm2 start npm --name "auxivie-dashboard" -- start
pm2 save
```

---

## 🔍 Vérifications

### 1. Vérifier .env.production

```bash
cat .env.production
```

Doit contenir exactement :
```
NEXT_PUBLIC_API_URL=https://api.auxivie.org
```

### 2. Vérifier que Node.js/npm est disponible

```bash
which node
which npm
node --version
npm --version
```

Si `npm` n'est pas trouvé, il faut l'installer ou utiliser le chemin complet.

### 3. Vérifier le Build

Après `npm run build`, vérifiez que le dossier `.next/` a été créé :

```bash
ls -la .next/
```

### 4. Vérifier que le Serveur Tourne

```bash
# Voir les processus Node.js
ps aux | grep node

# Ou avec PM2
pm2 status
```

---

## ⚠️ Si npm n'est pas Trouvé

### Option 1 : Utiliser le Chemin Complet

```bash
# Chercher npm
find /usr -name npm 2>/dev/null
find /usr/local -name npm 2>/dev/null

# Utiliser le chemin complet trouvé
/chemin/vers/npm install
```

### Option 2 : Installer Node.js via hPanel

1. Allez dans hPanel
2. Cherchez "Node.js" ou "Node.js Selector"
3. Installez Node.js (version 18 ou supérieure)

### Option 3 : Utiliser nvm (si disponible)

```bash
# Charger nvm
source ~/.nvm/nvm.sh

# Installer Node.js
nvm install 18
nvm use 18

# Vérifier
node --version
npm --version
```

---

## 🧪 Test Final

Après avoir démarré le serveur :

1. Ouvrez `https://www.auxivie.org` dans votre navigateur
2. Vous devriez voir le Dashboard ou être redirigé vers `/login`
3. Ouvrez la console (F12) → onglet "Network"
4. Tentez de vous connecter avec `admin@auxivie.com` / `admin123`
5. Vérifiez que les requêtes vont vers `https://api.auxivie.org/api/auth/login`

---

## 📋 Checklist

- [ ] Dashboard déployé dans `public_html/admin_dashboard/`
- [ ] Fichier `.env.production` créé avec `NEXT_PUBLIC_API_URL=https://api.auxivie.org`
- [ ] Dépendances installées (`npm install`)
- [ ] Dashboard buildé (`npm run build`)
- [ ] Serveur démarré (`npm start` ou PM2)
- [ ] Test de connexion réussi

---

**Exécutez les commandes dans l'ordre pour finaliser le déploiement !**

