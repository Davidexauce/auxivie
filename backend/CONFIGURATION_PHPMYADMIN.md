# 🔧 Configuration MySQL via phpMyAdmin

## 🌐 Accès phpMyAdmin

**URL** : https://auth-db1232.hstgr.io/index.php?db=u133413376_auxivie

La base de données `u133413376_auxivie` est déjà dans l'URL, ce qui signifie qu'elle existe !

---

## 🔑 Étape 1 : Se Connecter à phpMyAdmin

1. **Ouvrez le lien** : https://auth-db1232.hstgr.io/index.php?db=u133413376_auxivie
2. **Connectez-vous** avec vos identifiants MySQL :
   - **Username** : `u133413376_root` (ou votre utilisateur MySQL)
   - **Password** : `Auxivie2025` (ou votre mot de passe MySQL)

---

## ✅ Étape 2 : Vérifier la Base de Données

Une fois connecté :

1. **Vérifiez que la base `u133413376_auxivie` est visible** dans le menu de gauche
2. **Cliquez dessus** pour l'ouvrir
3. **Vérifiez les tables** - Vous devriez voir :
   - `users`
   - `reservations`
   - `messages`
   - `documents`
   - etc.

---

## 👤 Étape 3 : Vérifier/Créer l'Utilisateur MySQL

### Dans phpMyAdmin

1. **Cliquez sur l'onglet "Comptes d'utilisateurs"** (en haut)
   - OU allez dans **"Privilèges"** dans le menu de gauche

2. **Cherchez l'utilisateur** `u133413376_root`

3. **Si l'utilisateur existe** :
   - Cliquez sur **"Modifier les privilèges"**
   - Vérifiez que le mot de passe est `Auxivie2025`
   - Vérifiez que les privilèges sur `u133413376_auxivie` sont **"Tous les privilèges"**
   - Cliquez sur **"Exécuter"**

4. **Si l'utilisateur n'existe pas** :
   - Cliquez sur **"Ajouter un compte d'utilisateur"**
   - **Nom d'utilisateur** : `u133413376_root`
   - **Hôte** : `localhost`
   - **Mot de passe** : `Auxivie2025`
   - **Confirmer le mot de passe** : `Auxivie2025`
   - Dans **"Base de données pour la base de données spécifique"** :
     - Sélectionnez `u133413376_auxivie`
     - Cochez **"Tous les privilèges"**
   - Cliquez sur **"Exécuter"**

---

## 🔍 Étape 4 : Tester la Connexion

### Test 1 : Depuis phpMyAdmin

1. **Déconnectez-vous** de phpMyAdmin
2. **Reconnectez-vous** avec :
   - **Username** : `u133413376_root`
   - **Password** : `Auxivie2025`
3. Si vous pouvez vous connecter, les credentials sont corrects !

### Test 2 : Depuis le VPS

Sur le VPS :

```bash
cd ~/backend/backend

# Test direct MySQL
mysql -u u133413376_root -pAuxivie2025 u133413376_auxivie -e "SELECT 1"
```

Si ça fonctionne, vous verrez `1`.

---

## 📝 Étape 5 : Vérifier le Fichier .env

Sur le VPS :

```bash
cd ~/backend/backend
cat .env
```

Vérifiez que les valeurs sont **exactement** :

```env
DB_HOST=localhost
DB_USER=u133413376_root
DB_PASSWORD=Auxivie2025
DB_NAME=u133413376_auxivie
DB_PORT=3306
```

**⚠️ Important** : 
- Pas d'espaces avant/après le `=`
- Pas de guillemets autour des valeurs
- Le mot de passe est exactement `Auxivie2025` (sensible à la casse)

---

## 🚀 Étape 6 : Redémarrer le Backend

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

## 🐛 Si ça ne Fonctionne Toujours Pas

### Vérifier dans phpMyAdmin

1. **Onglet "SQL"** dans phpMyAdmin
2. **Exécutez cette requête** :

```sql
SELECT user, host FROM mysql.user WHERE user = 'u133413376_root';
```

Si aucun résultat, l'utilisateur n'existe pas.

3. **Créer l'utilisateur via SQL** :

```sql
CREATE USER 'u133413376_root'@'localhost' IDENTIFIED BY 'Auxivie2025';
GRANT ALL PRIVILEGES ON u133413376_auxivie.* TO 'u133413376_root'@'localhost';
FLUSH PRIVILEGES;
```

### Vérifier les Privilèges

Dans phpMyAdmin, onglet **"Privilèges"** :

1. Trouvez `u133413376_root@localhost`
2. Cliquez sur **"Modifier les privilèges"**
3. Vérifiez que **"Tous les privilèges"** est coché pour `u133413376_auxivie`
4. Cliquez sur **"Exécuter"**

---

## ✅ Checklist

- [ ] Connecté à phpMyAdmin avec succès
- [ ] Base de données `u133413376_auxivie` visible
- [ ] Tables présentes dans la base
- [ ] Utilisateur `u133413376_root` existe
- [ ] Mot de passe de l'utilisateur est `Auxivie2025`
- [ ] Privilèges "Tous les privilèges" sur la base
- [ ] Test MySQL direct réussi (`mysql -u user -p`)
- [ ] Fichier `.env` vérifié (pas d'espaces, valeurs exactes)
- [ ] Backend redémarré
- [ ] Logs montrent "✅ Connexion MySQL établie"

---

## 💡 Astuce

Si vous pouvez vous connecter à phpMyAdmin avec `u133413376_root` et `Auxivie2025`, alors les credentials sont corrects. Le problème vient probablement de :
1. Des espaces dans le fichier `.env`
2. Un caractère invisible dans le mot de passe
3. Le fichier `.env` n'est pas au bon endroit

**Vérifiez le fichier `.env` ligne par ligne !**

---

**Utilisez phpMyAdmin pour vérifier et corriger la configuration MySQL ! 🎉**

