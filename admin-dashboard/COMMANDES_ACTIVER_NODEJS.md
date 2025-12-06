# ✅ Activer Node.js sur Hostinger

## 🎯 Node.js Trouvé !

Node.js est installé dans `/opt/alt/alt-nodejs18/root/usr/bin/node` (et autres versions).

---

## 🚀 Solution Rapide : Utiliser le Chemin Complet

### Option 1 : Utiliser Directement les Chemins Complets

```bash
cd ~/domains/auxivie.org/public_html/admin_dashboard

# Utiliser Node.js 18
/opt/alt/alt-nodejs18/root/usr/bin/node --version
/opt/alt/alt-nodejs18/root/usr/bin/npm --version

# Installer les dépendances
/opt/alt/alt-nodejs18/root/usr/bin/npm install

# Builder le Dashboard
/opt/alt/alt-nodejs18/root/usr/bin/npm run build

# Démarrer le serveur
/opt/alt/alt-nodejs18/root/usr/bin/npm start
```

### Option 2 : Créer des Alias (pour cette session)

```bash
# Créer des alias
alias node='/opt/alt/alt-nodejs18/root/usr/bin/node'
alias npm='/opt/alt/alt-nodejs18/root/usr/lib/node_modules/npm/bin/npm'

# Vérifier
node --version
npm --version

# Maintenant vous pouvez utiliser npm directement
cd ~/domains/auxivie.org/public_html/admin_dashboard
npm install
npm run build
npm start
```

### Option 3 : Ajouter au PATH (pour cette session)

```bash
# Ajouter au PATH
export PATH="/opt/alt/alt-nodejs18/root/usr/bin:$PATH"
export PATH="/opt/alt/alt-nodejs18/root/usr/lib/node_modules/npm/bin:$PATH"

# Vérifier
node --version
npm --version

# Utiliser npm normalement
cd ~/domains/auxivie.org/public_html/admin_dashboard
npm install
npm run build
npm start
```

---

## 📋 Commandes Complètes à Exécuter

```bash
# 1. Aller dans admin_dashboard
cd ~/domains/auxivie.org/public_html/admin_dashboard

# 2. Activer Node.js (Option 3 - ajouter au PATH)
export PATH="/opt/alt/alt-nodejs18/root/usr/bin:$PATH"
export PATH="/opt/alt/alt-nodejs18/root/usr/lib/node_modules/npm/bin:$PATH"

# 3. Vérifier
node --version
npm --version

# 4. Installer les dépendances
npm install

# 5. Builder le Dashboard
npm run build

# 6. Démarrer le serveur
npm start
```

---

## 🔧 Solution Permanente : Ajouter au .bashrc

Pour que Node.js soit disponible à chaque connexion :

```bash
# Ajouter au .bashrc
echo 'export PATH="/opt/alt/alt-nodejs18/root/usr/bin:$PATH"' >> ~/.bashrc
echo 'export PATH="/opt/alt/alt-nodejs18/root/usr/lib/node_modules/npm/bin:$PATH"' >> ~/.bashrc

# Recharger
source ~/.bashrc

# Vérifier
node --version
npm --version
```

---

## 🎯 Versions Disponibles

- Node.js 18 : `/opt/alt/alt-nodejs18/root/usr/bin/node`
- Node.js 20 : `/opt/alt/alt-nodejs20/root/usr/bin/node`
- Node.js 22 : `/opt/alt/alt-nodejs22/root/usr/bin/node`
- Node.js 24 : `/opt/alt/alt-nodejs24/root/usr/bin/node`

**Recommandation** : Utilisez Node.js 18 ou 20 pour Next.js.

---

**Exécutez les commandes de l'Option 3 pour activer Node.js dans votre session actuelle !**

