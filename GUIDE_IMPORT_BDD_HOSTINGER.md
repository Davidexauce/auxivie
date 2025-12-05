# 📦 Guide d'Import de la Base de Données sur Hostinger

**Date :** 2024-12-19  
**Base de données :** SQLite (auxivie.db)

---

## 📋 Prérequis

- ✅ Base de données SQLite locale (`backend/data/auxivie.db`)
- ✅ Accès au panneau Hostinger (hPanel)
- ✅ Accès FTP/SSH ou File Manager de Hostinger
- ✅ Base de données MySQL/MariaDB créée dans Hostinger

---

## ⚠️ Important : Hostinger et SQLite

**Hostinger supporte MySQL/MariaDB, pas SQLite directement.**

Vous avez **2 options** :

### Option 1 : Continuer avec SQLite (Recommandé)
- Copier le fichier `.db` sur le serveur
- Le backend Node.js peut utiliser SQLite directement
- Plus simple, pas de conversion nécessaire

### Option 2 : Convertir vers MySQL/MariaDB
- Exporter SQLite vers SQL
- Importer dans MySQL/MariaDB
- Modifier le code backend pour utiliser MySQL

**Nous allons utiliser l'Option 1** (SQLite) car c'est plus simple et votre backend est déjà configuré pour SQLite.

---

## 📤 Étape 1 : Exporter/Préparer la Base de Données

### Méthode 1 : Copier directement le fichier .db

```bash
cd "/Users/david/Christelle Projet/backend"
# Le fichier est déjà prêt : data/auxivie.db
```

### Méthode 2 : Créer une sauvegarde

```bash
cd "/Users/david/Christelle Projet/backend"
node scripts/backup-db-simple.js
```

Cela créera une copie dans `backend/backups/auxivie-[timestamp].db`

### Méthode 3 : Exporter en SQL (si vous voulez convertir vers MySQL)

```bash
cd "/Users/david/Christelle Projet/backend"
node scripts/export-db.js
```

Cela créera `backend/data/auxivie-export.sql`

---

## 📥 Étape 2 : Uploader sur Hostinger

### Méthode A : Via File Manager (Recommandé)

1. **Accéder au File Manager dans Hostinger**
   - Connectez-vous à hPanel
   - Allez dans **"Files"** → **"File Manager"**

2. **Naviguer vers le dossier du backend**
   - Allez dans le dossier où se trouve votre backend
   - Exemple : `/domains/auxivie.org/public_html/backend/` ou `/domains/auxivie.org/backend/`

3. **Créer le dossier `data` s'il n'existe pas**
   - Cliquez sur "New Folder"
   - Nommez-le `data`

4. **Uploader le fichier**
   - Cliquez sur "Upload"
   - Sélectionnez `auxivie.db` depuis votre ordinateur
   - Attendez que l'upload se termine

5. **Vérifier les permissions**
   - Clic droit sur `auxivie.db` → "Change Permissions"
   - Définir à `644` ou `666` (lecture/écriture)

### Méthode B : Via FTP

1. **Se connecter en FTP**
   - Utilisez FileZilla ou un autre client FTP
   - Hôte : `ftp.auxivie.org` ou l'IP fournie par Hostinger
   - Identifiants : ceux fournis par Hostinger

2. **Naviguer vers le dossier backend**
   ```
   /domains/auxivie.org/backend/data/
   ```

3. **Uploader `auxivie.db`**
   - Glisser-déposer le fichier
   - Attendre la fin du transfert

### Méthode C : Via SSH (si disponible)

```bash
# Depuis votre machine locale
scp backend/data/auxivie.db username@hostinger-server:/path/to/backend/data/
```

---

## 🔧 Étape 3 : Vérifier la Configuration du Backend

### Vérifier le chemin de la base de données

Dans `backend/server.js`, le chemin doit être :

```javascript
const dbPath = path.join(__dirname, 'data', 'auxivie.db');
```

Cela fonctionnera si la structure est :
```
backend/
  ├── server.js
  ├── data/
  │   └── auxivie.db  ← Ici
  └── ...
```

### Vérifier les permissions

Le serveur Node.js doit pouvoir :
- ✅ **Lire** la base de données
- ✅ **Écrire** dans la base de données (pour les mises à jour)

**Permissions recommandées :**
- Fichier `auxivie.db` : `644` ou `666`
- Dossier `data/` : `755` ou `777`

---

## 🧪 Étape 4 : Tester la Connexion

### 1. Vérifier que le backend démarre

Dans les logs Hostinger, vérifier :
- ✅ Pas d'erreur "Cannot open database"
- ✅ Le serveur démarre correctement
- ✅ Les routes API répondent

### 2. Tester une requête API

```bash
curl https://api.auxivie.org/api/users?userType=professionnel
```

Ou depuis le dashboard :
- Se connecter au dashboard
- Vérifier que les utilisateurs s'affichent

---

## 📊 Vérification des Données

### Compter les enregistrements

Dans Hostinger, via SSH (si disponible) :

```bash
cd /path/to/backend
sqlite3 data/auxivie.db "SELECT COUNT(*) FROM users;"
sqlite3 data/auxivie.db "SELECT COUNT(*) FROM reservations;"
sqlite3 data/auxivie.db "SELECT COUNT(*) FROM messages;"
```

### Vérifier les tables

```bash
sqlite3 data/auxivie.db ".tables"
```

---

## 🔄 Mise à Jour de la Base de Données

### Si vous devez mettre à jour la base de données :

1. **Exporter la nouvelle version locale**
   ```bash
   node scripts/backup-db-simple.js
   ```

2. **Uploader le nouveau fichier**
   - Remplacer `auxivie.db` sur Hostinger
   - ⚠️ **Attention :** Cela écrasera l'ancienne base

3. **Redémarrer le backend**
   - Dans Hostinger, redémarrer l'application Node.js

---

## ⚠️ Précautions

### Sauvegarde avant import

**Toujours faire une sauvegarde avant de remplacer la base de données !**

```bash
# Sur Hostinger, via SSH
cp data/auxivie.db data/auxivie.db.backup-$(date +%Y%m%d)
```

### Permissions

- Le serveur Node.js doit avoir les droits de lecture/écriture
- Vérifier que le dossier `data/` existe et est accessible

### Taille du fichier

- La base de données fait environ **80 KB** (actuellement)
- Vérifier que vous avez assez d'espace sur Hostinger

---

## 🐛 Dépannage

### Problème : "Cannot open database"

**Solutions :**
- Vérifier que le fichier existe au bon endroit
- Vérifier les permissions (644 ou 666)
- Vérifier que le chemin dans `server.js` est correct
- Vérifier que le dossier `data/` existe

### Problème : "Permission denied"

**Solutions :**
- Changer les permissions du fichier à `666`
- Changer les permissions du dossier `data/` à `777`
- Vérifier le propriétaire du fichier

### Problème : Les données ne s'affichent pas

**Solutions :**
- Vérifier que le fichier a bien été uploadé (taille correcte)
- Vérifier les logs du backend
- Tester une requête API directement

---

## 📝 Checklist d'Import

- [ ] Base de données locale exportée/sauvegardée
- [ ] Fichier `auxivie.db` uploadé sur Hostinger
- [ ] Fichier placé dans `backend/data/auxivie.db`
- [ ] Permissions configurées (644 ou 666)
- [ ] Backend redémarré
- [ ] Test de connexion réussi
- [ ] Données visibles dans le dashboard
- [ ] Sauvegarde créée sur Hostinger

---

## 🔗 Fichiers Utiles

- **Script d'export SQL :** `backend/scripts/export-db.js`
- **Script de sauvegarde :** `backend/scripts/backup-db-simple.js`
- **Base de données :** `backend/data/auxivie.db`

---

**Date de création :** 2024-12-19

