# 🔧 Configuration de l'URL API pour le Dashboard

## ❌ Problème Actuel

Le Dashboard utilise par défaut `http://localhost:3001` qui ne fonctionne pas en production.

---

## ✅ Solution

### Configuration Actuelle

Le fichier `lib/api.js` utilise :

```javascript
const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001';
```

**✅ Correct** : Il utilise la variable d'environnement `NEXT_PUBLIC_API_URL`.

---

## 🔧 Configuration en Production

### Sur Hostinger (File Manager)

1. **Connectez-vous au File Manager de Hostinger**
2. **Naviguez vers** : `domains/auxivie.org/public_html/admin-dashboard/`
3. **Créez un fichier** `.env.production` avec ce contenu :

```env
NEXT_PUBLIC_API_URL=https://api.auxivie.org
```

### Via SSH (si vous avez accès)

```bash
cd ~/domains/auxivie.org/public_html/admin-dashboard
echo "NEXT_PUBLIC_API_URL=https://api.auxivie.org" > .env.production
```

---

## 🔄 Rebuild Nécessaire

**⚠️ IMPORTANT** : Après avoir créé/modifié `.env.production`, vous **devez rebuilder** le Dashboard :

```bash
cd admin-dashboard
npm run build
npm start
```

Les variables `NEXT_PUBLIC_*` sont injectées **au moment du build**, pas au runtime.

---

## 🧪 Vérification

### 1. Vérifier le fichier .env.production

```bash
cat .env.production
```

Devrait afficher :
```
NEXT_PUBLIC_API_URL=https://api.auxivie.org
```

### 2. Vérifier dans le navigateur

1. Ouvrez `https://www.auxivie.org`
2. Ouvrez la console (F12)
3. Allez dans l'onglet **"Network"**
4. Essayez de vous connecter
5. Vérifiez que les requêtes vont vers `https://api.auxivie.org/api/auth/login`

### 3. Test dans la console JavaScript

Dans la console du navigateur :

```javascript
// Vérifier la variable d'environnement
console.log(process.env.NEXT_PUBLIC_API_URL);
// Devrait afficher: https://api.auxivie.org
```

---

## 📋 Checklist

- [ ] Fichier `.env.production` créé sur Hostinger
- [ ] Contenu : `NEXT_PUBLIC_API_URL=https://api.auxivie.org`
- [ ] Dashboard rebuild (`npm run build`)
- [ ] Serveur redémarré (`npm start`)
- [ ] Test de connexion depuis le Dashboard
- [ ] Vérification dans la console du navigateur (Network tab)

---

## 🔍 Dépannage

### Si les requêtes vont toujours vers localhost

1. Vérifiez que `.env.production` existe et contient la bonne URL
2. **Rebuild** le Dashboard : `npm run build`
3. Redémarrez le serveur : `npm start`
4. Videz le cache du navigateur (Ctrl+Shift+R)

### Si vous obtenez des erreurs CORS

Vérifiez que le backend autorise les requêtes depuis `https://www.auxivie.org` :

Dans `backend/.env` :
```env
CORS_ORIGIN=https://www.auxivie.org
```

---

## 💡 Note

Le fichier `.env.production` est dans `.gitignore` (normal, il ne doit pas être commité). Vous devez le créer manuellement sur Hostinger.

---

**Une fois le fichier créé et le Dashboard rebuild, il pointera vers `https://api.auxivie.org` !**

