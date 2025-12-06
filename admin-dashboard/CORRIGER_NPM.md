# 🔧 Corriger le Problème npm

## ❌ Problème

Le PATH pour npm est incorrect. npm se trouve dans `/opt/alt/alt-nodejs18/root/usr/lib/node_modules/npm/bin/npm`, pas dans `/opt/alt/alt-nodejs18/root/usr/bin/`.

---

## ✅ Solution : Utiliser le Chemin Complet

### Option 1 : Utiliser Directement les Chemins Complets

```bash
# Aller dans admin_dashboard
cd ~/domains/auxivie.org/public_html/admin_dashboard

# Vérifier que vous êtes dans le bon dossier
pwd

# Utiliser les chemins complets
/opt/alt/alt-nodejs18/root/usr/bin/node --version
/opt/alt/alt-nodejs18/root/usr/lib/node_modules/npm/bin/npm --version

# Installer les dépendances
/opt/alt/alt-nodejs18/root/usr/lib/node_modules/npm/bin/npm install

# Builder
/opt/alt/alt-nodejs18/root/usr/lib/node_modules/npm/bin/npm run build

# Démarrer
/opt/alt/alt-nodejs18/root/usr/lib/node_modules/npm/bin/npm start
```

### Option 2 : Corriger le PATH dans .bashrc

```bash
# Éditer .bashrc
nano ~/.bashrc

# Supprimer les lignes incorrectes et ajouter :
export PATH="/opt/alt/alt-nodejs18/root/usr/bin:$PATH"
export PATH="/opt/alt/alt-nodejs18/root/usr/lib/node_modules/npm/bin:$PATH"

# Sauvegarder (Ctrl+X, Y, Entrée)

# Recharger
source ~/.bashrc

# Vérifier
node --version
npm --version
```

### Option 3 : Créer des Alias

```bash
# Créer des alias pour cette session
alias node='/opt/alt/alt-nodejs18/root/usr/bin/node'
alias npm='/opt/alt/alt-nodejs18/root/usr/lib/node_modules/npm/bin/npm'

# Vérifier
node --version
npm --version

# Utiliser normalement
npm install
npm run build
npm start
```

---

## 🔍 Vérifier le Dossier Actuel

Il y a aussi une erreur "getcwd: cannot access parent directories". Vérifiez :

```bash
# Vérifier où vous êtes
pwd

# Si le dossier n'existe plus, recréer le chemin
cd ~
cd domains/auxivie.org/public_html/admin_dashboard

# Vérifier que le dossier existe
ls -la
```

---

## 📋 Commandes Complètes (Option 1 - Recommandé)

```bash
# 1. Aller dans admin_dashboard
cd ~/domains/auxivie.org/public_html/admin_dashboard

# 2. Vérifier le dossier
pwd
ls -la package.json

# 3. Installer avec le chemin complet
/opt/alt/alt-nodejs18/root/usr/lib/node_modules/npm/bin/npm install

# 4. Builder avec le chemin complet
/opt/alt/alt-nodejs18/root/usr/lib/node_modules/npm/bin/npm run build

# 5. Démarrer avec le chemin complet
/opt/alt/alt-nodejs18/root/usr/lib/node_modules/npm/bin/npm start
```

---

**Utilisez l'Option 1 avec les chemins complets pour éviter les problèmes de PATH !**

