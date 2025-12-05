# 🚀 Upload Base de Données - Guide Rapide

## 📁 Fichier à Uploader

**Fichier :** `auxivie.db`  
**Taille :** 80 KB  
**Emplacement local :** `/Users/david/Christelle Projet/backend/data/auxivie.db`

---

## ⚡ Méthode Rapide (3 Étapes)

### 1️⃣ Ouvrir le Fichier

**Sur votre Mac :**
```bash
cd "/Users/david/Christelle Projet/backend"
./scripts/open-for-upload.sh
```

Ou manuellement :
- Ouvrir le Finder
- Aller dans : `/Users/david/Christelle Projet/backend/data/`
- Vous verrez le fichier `auxivie.db`

### 2️⃣ Uploader sur Hostinger

1. **Connectez-vous à Hostinger hPanel**
2. **Ouvrez le File Manager**
3. **Naviguez vers :** `domains/auxivie.org/backend/data/`
   - Si le dossier `data/` n'existe pas, créez-le
4. **Cliquez sur "Upload"**
5. **Glissez-déposez** `auxivie.db` dans la zone d'upload
   - OU cliquez "Select Files" et choisissez `auxivie.db`
6. **Attendez** que l'upload se termine (~80 KB, très rapide)

### 3️⃣ Configurer les Permissions

1. **Clic droit** sur `auxivie.db` dans le File Manager
2. **"Change Permissions"** ou **"Modifier les permissions"**
3. **Entrez :** `644` ou `666`
4. **Cliquez "Change"**

### 4️⃣ Redémarrer le Backend

1. Dans hPanel, allez dans **"Node.js"**
2. Trouvez votre application backend
3. Cliquez sur **"Restart"**

---

## ✅ Vérification

Testez l'API :
```
https://api.auxivie.org/api/users?userType=professionnel
```

Ou connectez-vous au dashboard :
```
https://www.auxivie.org
```

---

## 🆘 Problème ?

**"Cannot open database"**
- Vérifiez que le fichier est dans `backend/data/auxivie.db`
- Vérifiez les permissions (644 ou 666)
- Redémarrez le backend

**Le fichier n'apparaît pas**
- Rafraîchissez le File Manager (F5)
- Vérifiez que vous êtes dans le bon dossier

---

**C'est tout ! 🎉**

