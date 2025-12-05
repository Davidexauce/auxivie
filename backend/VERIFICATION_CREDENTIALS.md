# ✅ Vérification des Credentials MySQL

## 📋 Credentials Fournis

```env
DB_HOST=localhost
DB_USER=u133413376_root
DB_PASSWORD=Auxivie2025
DB_NAME=u133413376_auxivie
DB_PORT=3306
```

---

## 🔍 Tests à Effectuer sur le VPS

### Test 1 : Connexion MySQL Directe

```bash
mysql -u u133413376_root -p u133413376_auxivie
```

Quand demandé, entrez le mot de passe : `Auxivie2025`

**Si ça fonctionne** : Vous verrez le prompt MySQL `mysql>`

**Si ça échoue** : Vérifiez les credentials dans Hostinger hPanel

### Test 2 : Vérifier que la Base Existe

Une fois connecté à MySQL :

```sql
-- Voir les bases de données
SHOW DATABASES;

-- Utiliser la base
USE u133413376_auxivie;

-- Voir les tables
SHOW TABLES;

-- Quitter
EXIT;
```

### Test 3 : Test depuis Node.js

Sur le VPS :

```bash
cd ~/backend/backend

# Télécharger le script de test
# OU créer le fichier manuellement
nano test-connection.js
```

Collez le contenu de `scripts/test-connection-with-credentials.js`

Puis :

```bash
node test-connection.js
```

---

## 🔧 Si la Connexion Échoue

### Problème : "Access denied"

**Solutions :**

1. **Vérifier les credentials dans Hostinger hPanel**
   - Allez dans "Databases" → "MySQL Databases"
   - Vérifiez le nom d'utilisateur et le mot de passe

2. **Réinitialiser le mot de passe MySQL**
   ```bash
   mysql -u root -p
   ```
   Puis :
   ```sql
   ALTER USER 'u133413376_root'@'localhost' IDENTIFIED BY 'Auxivie2025';
   FLUSH PRIVILEGES;
   EXIT;
   ```

3. **Vérifier les permissions**
   ```sql
   SHOW GRANTS FOR 'u133413376_root'@'localhost';
   ```

### Problème : "Unknown database"

**Solutions :**

1. **Créer la base de données**
   ```sql
   CREATE DATABASE IF NOT EXISTS u133413376_auxivie CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   ```

2. **Importer les données**
   ```bash
   # Si vous avez le fichier SQL
   mysql -u u133413376_root -p u133413376_auxivie < auxivie-mysql.sql
   ```

---

## ✅ Une Fois la Connexion Vérifiée

### Mettre à Jour le .env

Assurez-vous que votre `.env` contient exactement :

```env
PORT=3001
NODE_ENV=production
DB_HOST=localhost
DB_USER=u133413376_root
DB_PASSWORD=Auxivie2025
DB_NAME=u133413376_auxivie
DB_PORT=3306
JWT_SECRET=une_cle_secrete_aleatoire
CORS_ORIGIN=https://www.auxivie.org
```

### Redémarrer le Backend

```bash
cd ~/backend/backend
npm start
```

Vous devriez voir :
```
✅ Connexion MySQL établie
✅ Base de données MySQL initialisée
🚀 Serveur API démarré sur http://localhost:3001
```

---

## 🎯 Checklist

- [ ] Test MySQL direct réussi (`mysql -u user -p database`)
- [ ] Base de données existe et contient des tables
- [ ] Fichier `.env` contient les bons credentials
- [ ] Test Node.js réussi (`node test-connection.js`)
- [ ] Backend démarre sans erreur

---

**Une fois tous les tests passés, votre backend sera opérationnel ! 🎉**

