# 🔧 Solution : Access Denied MySQL

## ❌ Erreur

```
Access denied for user 'u133413376_root'@'localhost' (using password: YES)
```

---

## 🔍 Diagnostic

### Sur le VPS, exécutez :

```bash
cd ~/backend/backend

# Télécharger le script de diagnostic
# OU créer le fichier manuellement
bash scripts/diagnose-mysql.sh
```

---

## 🔧 Solutions

### Solution 1 : Vérifier les Credentials dans Hostinger

1. **Connectez-vous à Hostinger hPanel**
2. Allez dans **"Databases"** → **"MySQL Databases"**
3. **Vérifiez exactement** :
   - Le nom d'utilisateur MySQL
   - Le mot de passe MySQL
   - Le nom de la base de données

**⚠️ Important** : Les credentials peuvent être différents de ce que vous pensez !

### Solution 2 : Créer/Réinitialiser l'Utilisateur MySQL

Sur le VPS :

```bash
cd ~/backend/backend

# Essayer de se connecter en root MySQL
sudo mysql -u root
# OU
mysql -u root -p
```

Une fois dans MySQL :

```sql
-- Voir tous les utilisateurs
SELECT user, host FROM mysql.user;

-- Vérifier si votre utilisateur existe
SELECT user, host FROM mysql.user WHERE user = 'u133413376_root';

-- Si l'utilisateur n'existe pas, le créer
CREATE USER 'u133413376_root'@'localhost' IDENTIFIED BY 'Auxivie2025';

-- OU si l'utilisateur existe, réinitialiser le mot de passe
ALTER USER 'u133413376_root'@'localhost' IDENTIFIED BY 'Auxivie2025';

-- Créer la base de données si elle n'existe pas
CREATE DATABASE IF NOT EXISTS u133413376_auxivie CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Donner tous les privilèges
GRANT ALL PRIVILEGES ON u133413376_auxivie.* TO 'u133413376_root'@'localhost';

-- Appliquer les changements
FLUSH PRIVILEGES;

-- Vérifier les permissions
SHOW GRANTS FOR 'u133413376_root'@'localhost';

-- Quitter
EXIT;
```

### Solution 3 : Utiliser le Script Automatique

Sur le VPS :

```bash
cd ~/backend/backend
bash scripts/fix-mysql-user.sh
```

Le script vous guidera pour créer/configurer l'utilisateur.

---

## ✅ Test de la Connexion

### Test 1 : Depuis MySQL

```bash
mysql -u u133413376_root -p u133413376_auxivie
```

Entrez le mot de passe : `Auxivie2025`

Si ça fonctionne, vous verrez `mysql>`

### Test 2 : Depuis Node.js

```bash
cd ~/backend/backend
node scripts/test-mysql-connection.js
```

---

## 🔄 Si Rien ne Fonctionne

### Option A : Créer un Nouvel Utilisateur

```sql
-- Se connecter en root
mysql -u root -p

-- Créer un nouvel utilisateur
CREATE USER 'auxivie_api'@'localhost' IDENTIFIED BY 'NouveauMotDePasse123!';
GRANT ALL PRIVILEGES ON u133413376_auxivie.* TO 'auxivie_api'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

Puis mettez à jour `.env` :

```env
DB_USER=auxivie_api
DB_PASSWORD=NouveauMotDePasse123!
```

### Option B : Utiliser les Credentials Hostinger Exactes

1. Dans Hostinger hPanel → MySQL Databases
2. **Copiez exactement** :
   - Database Name
   - Database User
   - Database Password
3. Mettez à jour `.env` avec ces valeurs exactes

---

## 📝 Mettre à Jour .env

```bash
cd ~/backend/backend
nano .env
```

Assurez-vous que les valeurs sont **exactement** celles de Hostinger :

```env
DB_HOST=localhost
DB_USER=u133413376_root          # OU l'utilisateur exact de Hostinger
DB_PASSWORD=Auxivie2025          # OU le mot de passe exact de Hostinger
DB_NAME=u133413376_auxivie       # OU le nom exact de Hostinger
DB_PORT=3306
```

---

## 🚀 Redémarrer le Backend

Une fois la connexion testée et fonctionnelle :

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

## 🆘 Besoin d'Aide ?

Si rien ne fonctionne, vérifiez :

1. **MySQL est-il démarré ?**
   ```bash
   sudo systemctl status mysql
   ```

2. **Le port 3306 est-il ouvert ?**
   ```bash
   sudo netstat -tulpn | grep 3306
   ```

3. **Les credentials sont-ils corrects ?**
   - Vérifiez dans Hostinger hPanel
   - Testez avec `mysql -u user -p`

---

**Essayez d'abord la Solution 2 pour créer/réinitialiser l'utilisateur MySQL !**

