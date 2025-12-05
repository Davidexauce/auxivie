# 📤 Guide Étape par Étape - Upload Base de Données sur Hostinger

## 🎯 Objectif

Uploader le fichier `auxivie.db` (80 KB) sur Hostinger pour que le backend puisse l'utiliser.

---

## 📁 Fichier à Uploader

**Emplacement local :** `/Users/david/Christelle Projet/backend/data/auxivie.db`  
**Taille :** 80 KB  
**Emplacement sur Hostinger :** `backend/data/auxivie.db`

---

## 🚀 Méthode : File Manager Hostinger (La Plus Simple)

### ÉTAPE 1 : Se Connecter à Hostinger

1. Allez sur https://www.hostinger.com
2. Cliquez sur **"Se connecter"** ou **"Login"**
3. Entrez vos identifiants
4. Accédez au **hPanel**

### ÉTAPE 2 : Ouvrir le File Manager

1. Dans le hPanel, cherchez la section **"Files"**
2. Cliquez sur **"File Manager"**
3. Une nouvelle fenêtre/onglet s'ouvre avec l'explorateur de fichiers

### ÉTAPE 3 : Naviguer vers le Dossier Backend

**Option A : Si le backend est dans public_html**
```
public_html/
  └── backend/
      └── data/  ← Ici
```

**Option B : Si le backend est à la racine du domaine**
```
domains/
  └── auxivie.org/
      └── backend/
          └── data/  ← Ici
```

**Actions :**
1. Double-cliquez sur les dossiers pour naviguer
2. Trouvez le dossier `backend`
3. Ouvrez-le
4. **Si le dossier `data` n'existe pas :**
   - Clic droit dans le dossier `backend`
   - Cliquez sur **"New Folder"** ou **"Nouveau dossier"**
   - Nommez-le `data`
   - Appuyez sur Entrée

### ÉTAPE 4 : Uploader le Fichier

1. **Ouvrir le dossier `data/`** (double-clic)

2. **Cliquer sur "Upload"** (bouton en haut de la page)

3. **Deux options :**
   
   **Option A : Glisser-Déposer**
   - Ouvrir le Finder sur votre Mac
   - Naviguer vers : `/Users/david/Christelle Projet/backend/data/`
   - Glisser le fichier `auxivie.db` dans la zone d'upload du File Manager
   - Attendre que l'upload se termine

   **Option B : Sélectionner le Fichier**
   - Cliquer sur "Select Files" ou "Choisir des fichiers"
   - Naviguer vers : `/Users/david/Christelle Projet/backend/data/`
   - Sélectionner `auxivie.db`
   - Cliquer sur "Open" ou "Ouvrir"
   - Attendre que l'upload se termine

4. **Vérifier que le fichier est présent**
   - Vous devriez voir `auxivie.db` dans le dossier `data/`
   - Vérifier la taille : ~80 KB

### ÉTAPE 5 : Configurer les Permissions

1. **Clic droit sur `auxivie.db`**
2. Cliquez sur **"Change Permissions"** ou **"Modifier les permissions"**
3. **Définir les permissions :**
   - Cochez : **Read** (Lecture) pour Owner, Group, Public
   - Cochez : **Write** (Écriture) pour Owner
   - Ou simplement entrer : **644** ou **666**
4. Cliquez sur **"Change"** ou **"Modifier"**

### ÉTAPE 6 : Redémarrer le Backend

1. **Retourner au hPanel**
2. Allez dans **"Advanced"** → **"Node.js"** (ou **"Websites"** → **"Node.js"**)
3. **Trouvez votre application backend**
4. Cliquez sur **"Restart"** ou **"Redémarrer"**
5. Attendez quelques secondes

---

## ✅ Vérification

### 1. Vérifier les Logs

Dans Hostinger, dans la section Node.js :
1. Cliquez sur votre application backend
2. Allez dans **"Logs"** ou **"View Logs"**
3. Vérifiez qu'il n'y a **pas d'erreur** "Cannot open database"
4. Vous devriez voir : `🚀 Serveur API démarré sur http://localhost:3001`

### 2. Tester l'API

Ouvrez un navigateur et testez :
```
https://api.auxivie.org/api/users?userType=professionnel
```

Ou depuis le dashboard :
- Connectez-vous sur https://www.auxivie.org
- Vérifiez que les utilisateurs s'affichent

---

## 🐛 Problèmes Courants

### Problème : "Cannot open database"

**Solutions :**
1. Vérifier que le fichier est bien dans `backend/data/auxivie.db`
2. Vérifier les permissions (644 ou 666)
3. Vérifier que le dossier `data/` existe
4. Redémarrer le backend

### Problème : "Permission denied"

**Solutions :**
1. Changer les permissions à **666** (lecture/écriture pour tous)
2. Vérifier le propriétaire du fichier
3. Contacter le support Hostinger si nécessaire

### Problème : Le fichier n'apparaît pas après upload

**Solutions :**
1. Rafraîchir la page du File Manager (F5)
2. Vérifier que vous êtes dans le bon dossier
3. Vérifier la taille du fichier uploadé (doit être ~80 KB)

---

## 📸 Capture d'Écran - Chemin Typique

```
hPanel
└── File Manager
    └── domains
        └── auxivie.org
            └── backend
                └── data
                    └── auxivie.db  ← ICI
```

---

## 🎯 Checklist Rapide

- [ ] Connecté à Hostinger hPanel
- [ ] File Manager ouvert
- [ ] Navigué vers `backend/data/`
- [ ] Dossier `data/` créé (si nécessaire)
- [ ] Fichier `auxivie.db` uploadé
- [ ] Permissions configurées (644 ou 666)
- [ ] Backend redémarré
- [ ] Logs vérifiés (pas d'erreur)
- [ ] API testée (données visibles)

---

## 💡 Astuce

**Si vous avez des difficultés avec le File Manager :**

Vous pouvez aussi utiliser **FTP** :
1. Obtenez les identifiants FTP dans Hostinger
2. Utilisez FileZilla ou un autre client FTP
3. Connectez-vous
4. Naviguez vers `backend/data/`
5. Glissez-déposez `auxivie.db`

---

**Une fois terminé, votre base de données sera accessible sur Hostinger ! 🎉**

