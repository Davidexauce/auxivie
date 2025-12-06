# 🔍 Chercher Node.js sur Hostinger

## 📋 Commandes à Exécuter

Exécutez ces commandes **une par une** :

### 1. Chercher Node.js dans /opt

```bash
find /opt -name node -type f 2>/dev/null | head -10
find /opt -name npm -type f 2>/dev/null | head -10
```

### 2. Chercher dans /usr/local

```bash
find /usr/local -name node -type f 2>/dev/null | head -10
find /usr/local -name npm -type f 2>/dev/null | head -10
```

### 3. Chercher dans /usr

```bash
find /usr -name node -type f 2>/dev/null | grep -v node_modules | head -10
find /usr -name npm -type f 2>/dev/null | grep -v node_modules | head -10
```

### 4. Chercher dans le home

```bash
find ~ -maxdepth 5 -name node -type f 2>/dev/null | grep -v node_modules | head -10
find ~ -maxdepth 5 -name npm -type f 2>/dev/null | grep -v node_modules | head -10
```

### 5. Vérifier les Chemins Alternatifs

```bash
# Chemins communs sur Hostinger
ls -la /opt/nodejs*/bin/node 2>/dev/null
ls -la /opt/alt-nodejs*/bin/node 2>/dev/null
ls -la /usr/local/nodejs*/bin/node 2>/dev/null
ls -la ~/.nvm/versions/*/bin/node 2>/dev/null
```

---

## 🎯 Si Node.js n'est Pas Trouvé

### Solution : Installer via hPanel

1. **Connectez-vous à hPanel** : https://hpanel.hostinger.com/
2. **Cherchez "Node.js"** dans la barre de recherche
3. **Cliquez sur "Node.js"** ou **"Node.js Manager"**
4. **Installez Node.js** (version 18 ou supérieure)
5. **Notez le chemin** d'installation affiché

---

## 💡 Alternative : Utiliser le Build Local

Si Node.js ne peut pas être installé sur Hostinger, vous pouvez :

1. **Builder le Dashboard localement** sur votre Mac
2. **Uploader le dossier `.next/`** et les fichiers buildés
3. **Utiliser le serveur Node.js** déjà configuré

---

**Commencez par exécuter les commandes de recherche ci-dessus !**

