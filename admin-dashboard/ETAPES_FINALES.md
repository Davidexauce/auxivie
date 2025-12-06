# ✅ Étapes Finales - Builder et Démarrer le Dashboard

## 📋 Commandes à Exécuter

### 1. Vérifier que Node.js Fonctionne

```bash
node --version
npm --version
```

Vous devriez voir les versions de Node.js et npm.

### 2. Installer les Dépendances

```bash
npm install
```

Cela peut prendre quelques minutes.

### 3. Builder le Dashboard (IMPORTANT !)

```bash
npm run build
```

Cela va créer le dossier `.next/` avec les fichiers buildés.

### 4. Démarrer le Serveur

```bash
npm start
```

Le serveur devrait démarrer sur le port 3000 (ou celui configuré).

---

## 🔧 Si npm n'est Toujours Pas Trouvé

Si `npm --version` ne fonctionne pas, utilisez le chemin complet :

```bash
# Utiliser le chemin complet
/opt/alt/alt-nodejs18/root/usr/bin/node --version
/opt/alt/alt-nodejs18/root/usr/lib/node_modules/npm/bin/npm --version

# Installer avec le chemin complet
/opt/alt/alt-nodejs18/root/usr/lib/node_modules/npm/bin/npm install
/opt/alt/alt-nodejs18/root/usr/lib/node_modules/npm/bin/npm run build
/opt/alt/alt-nodejs18/root/usr/lib/node_modules/npm/bin/npm start
```

---

## 📋 Checklist

- [ ] Node.js activé (`node --version` fonctionne)
- [ ] npm activé (`npm --version` fonctionne)
- [ ] Dépendances installées (`npm install`)
- [ ] Dashboard buildé (`npm run build`)
- [ ] Serveur démarré (`npm start`)

---

**Commencez par exécuter `node --version` et `npm --version` pour vérifier que tout fonctionne !**

