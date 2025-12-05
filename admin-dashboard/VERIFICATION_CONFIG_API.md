# ✅ Vérification Configuration API Dashboard

## 📋 Configuration Actuelle

### Fichier `lib/api.js`

```javascript
const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001';
```

**✅ Correct** : Utilise la variable d'environnement `NEXT_PUBLIC_API_URL` avec fallback sur localhost.

---

## 🔧 Configuration en Production

### Fichier `.env.production`

Créé avec :

```env
NEXT_PUBLIC_API_URL=https://api.auxivie.org
```

**✅ Correct** : Le Dashboard pointera vers `https://api.auxivie.org` en production.

---

## 🧪 Vérification

### 1. Vérifier que le fichier existe

```bash
cd admin-dashboard
cat .env.production
```

Vous devriez voir :
```
NEXT_PUBLIC_API_URL=https://api.auxivie.org
```

### 2. Rebuild le Dashboard

Après avoir créé/modifié `.env.production`, il faut rebuilder :

```bash
cd admin-dashboard
npm run build
```

### 3. Vérifier dans le code compilé

Le build Next.js injecte les variables `NEXT_PUBLIC_*` dans le code. Vérifiez que l'URL est correcte dans le build.

---

## ⚠️ Important

### Variables d'Environnement Next.js

- Les variables `NEXT_PUBLIC_*` sont **injectées au moment du build**
- Si vous modifiez `.env.production`, vous **devez rebuilder** :
  ```bash
  npm run build
  ```

### En Développement

Pour le développement local, créez un fichier `.env.local` :

```env
NEXT_PUBLIC_API_URL=http://localhost:3001
```

### En Production (Hostinger)

1. Le fichier `.env.production` doit contenir :
   ```env
   NEXT_PUBLIC_API_URL=https://api.auxivie.org
   ```

2. Rebuild le Dashboard :
   ```bash
   npm run build
   ```

3. Redémarrer le serveur :
   ```bash
   npm start
   ```

---

## 🔍 Vérification dans le Navigateur

### Console du Navigateur

1. Ouvrez `https://www.auxivie.org`
2. Ouvrez la console (F12)
3. Allez dans l'onglet "Network"
4. Essayez de vous connecter
5. Vérifiez que les requêtes vont vers `https://api.auxivie.org/api/auth/login`

### Test Direct

Dans la console du navigateur :

```javascript
console.log(process.env.NEXT_PUBLIC_API_URL);
// Devrait afficher: https://api.auxivie.org
```

---

## 📋 Checklist

- [ ] Fichier `.env.production` créé avec `NEXT_PUBLIC_API_URL=https://api.auxivie.org`
- [ ] Dashboard rebuild (`npm run build`)
- [ ] Serveur redémarré (`npm start`)
- [ ] Test de connexion depuis le Dashboard
- [ ] Vérification dans la console du navigateur (Network tab)

---

## 🚀 Actions sur Hostinger

Si le Dashboard est déjà déployé sur Hostinger :

1. **Connectez-vous au File Manager de Hostinger**
2. **Naviguez vers** : `domains/auxivie.org/public_html/admin-dashboard/`
3. **Créez ou modifiez** le fichier `.env.production` :
   ```
   NEXT_PUBLIC_API_URL=https://api.auxivie.org
   ```
4. **Via SSH** (si vous avez accès) :
   ```bash
   cd ~/domains/auxivie.org/public_html/admin-dashboard
   echo "NEXT_PUBLIC_API_URL=https://api.auxivie.org" > .env.production
   npm run build
   ```

---

**Le Dashboard est maintenant configuré pour pointer vers `https://api.auxivie.org` !**

