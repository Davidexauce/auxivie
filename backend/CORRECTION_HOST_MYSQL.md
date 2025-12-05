# 🔧 Correction : Problème d'Hôte MySQL

## ✅ Diagnostic Confirmé

Le diagnostic montre que :
- ✅ Les variables `.env` sont correctes
- ✅ Les valeurs correspondent exactement
- ❌ **Même avec valeurs codées en dur, la connexion échoue**

**Conclusion** : Le problème vient de MySQL, pas du fichier `.env`.

---

## 🎯 Problème Identifié

L'utilisateur `u133413376_root` peut se connecter via **phpMyAdmin** (qui utilise probablement `127.0.0.1` ou un autre hôte), mais **pas depuis `localhost`** sur le VPS.

En MySQL, `localhost` et `127.0.0.1` sont traités différemment :
- `localhost` = connexion via socket Unix
- `127.0.0.1` = connexion TCP/IP

L'utilisateur existe peut-être pour `127.0.0.1` mais pas pour `localhost`.

---

## 🔧 Solution : Vérifier et Corriger dans phpMyAdmin

### Étape 1 : Voir les Utilisateurs MySQL

1. Dans **phpMyAdmin**, cliquez sur **"Privilèges"** dans le menu de gauche
2. Cherchez `u133413376_root` dans la liste
3. Notez la colonne **"Hôte"** :
   - Si c'est `%` → devrait fonctionner partout
   - Si c'est `127.0.0.1` → ne fonctionne pas avec `localhost`
   - Si c'est `localhost` → devrait fonctionner

### Étape 2 : Modifier l'Utilisateur

1. Cliquez sur **"Modifier les privilèges"** (icône crayon) pour `u133413376_root`
2. Dans la section **"Modifier le compte d'utilisateur"** :
   - **Hôte** : Changez pour `%` (tous les hôtes) OU ajoutez `localhost`
3. Cliquez sur **"Exécuter"**

### Étape 3 : OU Créer un Utilisateur pour localhost

Si vous ne pouvez pas modifier l'hôte, créez un nouvel utilisateur :

1. **Onglet "Privilèges"** → **"Ajouter un compte d'utilisateur"**
2. Remplissez :
   - **Nom d'utilisateur** : `u133413376_root`
   - **Hôte** : `localhost` (important !)
   - **Mot de passe** : `Auxivie2025`
   - **Confirmer** : `Auxivie2025`
3. Dans **"Base de données pour la base de données spécifique"** :
   - Sélectionnez `u133413376_auxivie`
   - Cochez **"Tous les privilèges"**
4. Cliquez sur **"Exécuter"**

---

## 🔧 Solution Alternative : Utiliser 127.0.0.1 au lieu de localhost

Si vous ne pouvez pas modifier MySQL, changez le `.env` pour utiliser `127.0.0.1` :

```bash
cd ~/backend/backend

# Modifier DB_HOST
sed -i 's/DB_HOST=localhost/DB_HOST=127.0.0.1/' .env

# Vérifier
cat .env | grep DB_HOST
```

Puis testez :

```bash
npm start
```

---

## 🧪 Test Rapide : Vérifier l'Hôte MySQL

Dans phpMyAdmin, exécutez cette requête SQL :

```sql
SELECT user, host FROM mysql.user WHERE user = 'u133413376_root';
```

Vous devriez voir une ou plusieurs lignes. Si vous voyez :
- `u133413376_root | %` → devrait fonctionner
- `u133413376_root | 127.0.0.1` → ne fonctionne pas avec `localhost`
- `u133413376_root | localhost` → devrait fonctionner
- Pas de ligne avec `localhost` → **c'est le problème !**

---

## 🔧 Solution SQL Directe (si vous avez accès root)

Si vous avez accès root MySQL, exécutez dans phpMyAdmin :

```sql
-- Vérifier les utilisateurs existants
SELECT user, host FROM mysql.user WHERE user = 'u133413376_root';

-- Créer l'utilisateur pour localhost s'il n'existe pas
CREATE USER IF NOT EXISTS 'u133413376_root'@'localhost' IDENTIFIED BY 'Auxivie2025';

-- Donner tous les privilèges sur la base
GRANT ALL PRIVILEGES ON `u133413376_auxivie`.* TO 'u133413376_root'@'localhost';

-- Appliquer les changements
FLUSH PRIVILEGES;

-- Vérifier
SELECT user, host FROM mysql.user WHERE user = 'u133413376_root';
```

---

## 📋 Checklist

- [ ] Vérifié les hôtes dans phpMyAdmin (onglet Privilèges)
- [ ] Modifié l'utilisateur pour inclure `localhost` OU créé un nouvel utilisateur pour `localhost`
- [ ] OU changé `DB_HOST=127.0.0.1` dans `.env`
- [ ] Testé `npm start`

---

## 💡 Recommandation

**Option la plus simple** : Changez `DB_HOST=localhost` en `DB_HOST=127.0.0.1` dans le `.env` et testez.

Si ça ne fonctionne toujours pas, créez un utilisateur spécifique pour `localhost` dans phpMyAdmin.

---

**Commencez par vérifier les hôtes dans phpMyAdmin (onglet Privilèges) !**

