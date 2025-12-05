# 📋 Instructions Rapides : Créer .env.production sur Hostinger

## 🎯 Méthode la Plus Simple : File Manager

### Étape 1 : Accéder au File Manager

1. Connectez-vous à **Hostinger hPanel**
2. Cliquez sur **"File Manager"**

### Étape 2 : Naviguer vers le Dossier

1. Dans le File Manager, naviguez vers :
   ```
   domains/auxivie.org/public_html/admin-dashboard/
   ```

### Étape 3 : Créer le Fichier

1. Cliquez sur **"Nouveau fichier"** ou **"New File"**
2. **Nom du fichier** : `.env.production`
   - ⚠️ **Important** : Le nom commence par un point (`.`)
3. Cliquez sur **"Créer"** ou **"Create"**

### Étape 4 : Ajouter le Contenu

1. **Double-cliquez** sur le fichier `.env.production` pour l'éditer
2. **Collez ce contenu exactement** :
   ```
   NEXT_PUBLIC_API_URL=https://api.auxivie.org
   ```
3. **Sauvegardez** (Ctrl+S ou bouton Save)

### Étape 5 : Vérifier

Le fichier doit contenir exactement :
```
NEXT_PUBLIC_API_URL=https://api.auxivie.org
```

---

## 🔄 Après la Création : Rebuild

**⚠️ IMPORTANT** : Après avoir créé le fichier, vous devez rebuilder le Dashboard.

### Via SSH (si vous avez accès) :

```bash
cd ~/domains/auxivie.org/public_html/admin-dashboard
npm run build
npm start
```

### Via Terminal Hostinger (hPanel) :

1. Allez dans **"Terminal"** dans hPanel
2. Exécutez :
   ```bash
   cd ~/domains/auxivie.org/public_html/admin-dashboard
   npm run build
   npm start
   ```

---

## ✅ Vérification Finale

1. Ouvrez `https://www.auxivie.org` dans votre navigateur
2. Ouvrez la console (F12) → onglet **"Network"**
3. Essayez de vous connecter
4. Vérifiez que les requêtes vont vers `https://api.auxivie.org/api/auth/login`

---

## 🆘 Si ça ne fonctionne pas

### Vérifier que le fichier existe :

```bash
# Via SSH ou Terminal Hostinger
cd ~/domains/auxivie.org/public_html/admin-dashboard
ls -la | grep .env.production
cat .env.production
```

### Vérifier les permissions :

```bash
chmod 644 .env.production
```

### Rebuild complet :

```bash
cd ~/domains/auxivie.org/public_html/admin-dashboard
rm -rf .next
npm run build
npm start
```

---

**C'est tout ! Le fichier est maintenant sur Hostinger et le Dashboard pointera vers `https://api.auxivie.org`.**

