# 🔍 Trouver/Installer Node.js sur Hostinger

## ❌ Problème

`npm` et `node` ne sont pas trouvés dans le PATH.

---

## 🔍 Commandes pour Trouver Node.js

### 1. Chercher Node.js dans le Système

```bash
# Chercher node
find /usr -name node 2>/dev/null | head -10
find /usr/local -name node 2>/dev/null | head -10
find /opt -name node 2>/dev/null | head -10
find ~ -name node 2>/dev/null | head -10

# Chercher npm
find /usr -name npm 2>/dev/null | head -10
find /usr/local -name npm 2>/dev/null | head -10
find /opt -name npm 2>/dev/null | head -10
find ~ -name npm 2>/dev/null | head -10
```

### 2. Chercher via Node.js Selector (CloudLinux)

```bash
# Vérifier si Node.js Selector est disponible
which nodejs-selector
/usr/bin/nodejs-selector --list

# Activer une version de Node.js
/usr/bin/nodejs-selector --set-current 18
```

### 3. Chercher dans les Chemins Alternatifs

```bash
# Chemins communs pour Node.js sur Hostinger
ls -la /opt/nodejs*/bin/node 2>/dev/null
ls -la /opt/alt-nodejs*/bin/node 2>/dev/null
ls -la ~/.nvm/versions/*/bin/node 2>/dev/null
ls -la /usr/local/nodejs*/bin/node 2>/dev/null
```

---

## 🎯 Solution 1 : Utiliser Node.js Selector (CloudLinux)

Hostinger utilise souvent CloudLinux avec Node.js Selector :

```bash
# Lister les versions disponibles
/usr/bin/nodejs-selector --list

# Activer Node.js 18 (ou la version disponible)
/usr/bin/nodejs-selector --set-current 18

# Vérifier
node --version
npm --version
```

---

## 🎯 Solution 2 : Installer via hPanel

1. **Connectez-vous à hPanel** : https://hpanel.hostinger.com/
2. **Cherchez "Node.js"** ou **"Node.js Selector"**
3. **Installez Node.js** (version 18 ou supérieure)
4. **Activez la version** installée

---

## 🎯 Solution 3 : Utiliser le Chemin Complet

Si Node.js est installé mais pas dans le PATH :

```bash
# Trouver le chemin
NODE_PATH=$(find /opt -name node -type f 2>/dev/null | head -1 | xargs dirname)
NPM_PATH=$(find /opt -name npm -type f 2>/dev/null | head -1 | xargs dirname)

# Utiliser avec le chemin complet
$NODE_PATH/node --version
$NPM_PATH/npm install
```

---

## 🎯 Solution 4 : Installer via nvm (si disponible)

```bash
# Vérifier si nvm existe
ls -la ~/.nvm/nvm.sh

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

## 📋 Commandes à Exécuter

Commencez par :

```bash
# 1. Chercher nodejs-selector
which nodejs-selector
/usr/bin/nodejs-selector --list

# 2. Si trouvé, activer Node.js
/usr/bin/nodejs-selector --set-current 18

# 3. Vérifier
node --version
npm --version
```

---

**Commencez par exécuter `/usr/bin/nodejs-selector --list` pour voir les versions disponibles !**

