# 📤 Instructions Rapides - Upload Base de Données sur Hostinger

## 🎯 Objectif

Uploader le fichier `auxivie.db` sur Hostinger pour que le backend puisse l'utiliser.

---

## 📁 Fichier à Uploader

**Fichier :** `backend/data/auxivie.db`  
**Taille :** ~80 KB  
**Emplacement sur Hostinger :** `backend/data/auxivie.db`

---

## 🚀 Méthode Rapide : File Manager Hostinger

### Étape 1 : Préparer le fichier

Le fichier est déjà prêt :
```
/Users/david/Christelle Projet/backend/data/auxivie.db
```

### Étape 2 : Accéder au File Manager

1. Connectez-vous à **hPanel Hostinger**
2. Allez dans **"Files"** → **"File Manager"**
3. Naviguez vers votre domaine : `domains/auxivie.org/` ou `public_html/`

### Étape 3 : Trouver/Créer le dossier backend

- Si le backend est dans `public_html/backend/`, allez-y
- Si le backend est ailleurs, naviguez vers le bon dossier
- **Créer le dossier `data`** s'il n'existe pas :
  - Clic droit → "New Folder" → Nommer `data`

### Étape 4 : Uploader le fichier

1. Ouvrir le dossier `data/`
2. Cliquer sur **"Upload"** (en haut)
3. Glisser-déposer `auxivie.db` ou cliquer pour sélectionner
4. Attendre la fin de l'upload

### Étape 5 : Vérifier les permissions

1. Clic droit sur `auxivie.db` → **"Change Permissions"**
2. Définir à **`644`** ou **`666`**
3. Cliquer sur **"Change"**

---

## ✅ Vérification

### Vérifier que le fichier est présent

Dans le File Manager, vous devriez voir :
```
backend/
  ├── server.js
  ├── data/
  │   └── auxivie.db  ← Ici (80 KB)
  └── ...
```

### Vérifier les permissions

Le fichier doit avoir les permissions **644** ou **666**

---

## 🔄 Redémarrer le Backend

Après l'upload :

1. Dans Hostinger, allez dans **"Node.js Apps"**
2. Trouvez votre application backend
3. Cliquez sur **"Restart"** ou **"Redeploy"**

---

## 🧪 Tester

Une fois redémarré, tester :

1. Vérifier les logs dans Hostinger (pas d'erreur "Cannot open database")
2. Tester une requête API :
   ```
   https://api.auxivie.org/api/users?userType=professionnel
   ```
3. Vérifier dans le dashboard que les données s'affichent

---

## ⚠️ Important

- ✅ Le fichier doit être dans `backend/data/auxivie.db`
- ✅ Les permissions doivent être 644 ou 666
- ✅ Le backend doit être redémarré après l'upload
- ✅ Faire une sauvegarde avant de remplacer une base existante

---

**C'est tout ! Votre base de données est maintenant sur Hostinger.**

