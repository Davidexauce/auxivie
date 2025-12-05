# 📁 Déplacer .env.production vers admin_dashboard

## ✅ Solution

Le Dashboard est dans le dossier `admin_dashboard` (avec underscore).

---

## 🔧 Commandes à Exécuter

```bash
# 1. Aller dans public_html
cd ~/domains/auxivie.org/public_html

# 2. Vérifier que admin_dashboard existe
ls -la | grep admin_dashboard

# 3. Déplacer le fichier .env.production vers admin_dashboard
mv .env.production admin_dashboard/.env.production

# 4. Vérifier que le fichier est au bon endroit
cat admin_dashboard/.env.production

# 5. Aller dans admin_dashboard
cd admin_dashboard

# 6. Rebuild le Dashboard
npm run build

# 7. Redémarrer le serveur
npm start
```

---

## ✅ Vérification

Après le rebuild, le fichier `.env.production` sera dans :
```
~/domains/auxivie.org/public_html/admin_dashboard/.env.production
```

Et le Dashboard utilisera `https://api.auxivie.org` pour les appels API.

---

## 🧪 Test Final

1. Ouvrez `https://www.auxivie.org` dans votre navigateur
2. Ouvrez la console (F12) → onglet "Network"
3. Essayez de vous connecter
4. Vérifiez que les requêtes vont vers `https://api.auxivie.org/api/auth/login`

