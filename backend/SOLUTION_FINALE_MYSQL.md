# 🔧 Solution Finale : Erreur MySQL depuis Node.js

## ❌ Problème

- ✅ Connexion phpMyAdmin fonctionne avec `u133413376_root` / `Auxivie2025`
- ❌ Connexion Node.js échoue avec "Access denied"

Cela signifie que le problème vient du fichier `.env` ou de la façon dont Node.js lit les variables.

---

## 🔍 Diagnostic Étape par Étape

### Sur le VPS, exécutez :

```bash
cd ~/backend/backend

# 1. Voir le contenu exact du .env
cat -A .env | grep DB_

# 2. Exécuter le script de diagnostic
node scripts/debug-mysql-connection.js
```

Ce script va :
- Afficher les valeurs exactes lues par Node.js
- Détecter les espaces et caractères invisibles
- Comparer avec les valeurs attendues
- Tester avec valeurs codées en dur

---

## 🔧 Solution 1 : Recréer le Fichier .env Proprement

Sur le VPS :

```bash
cd ~/backend/backend

# Sauvegarder l'ancien
cp .env .env.backup

# Supprimer l'ancien
rm .env

# Créer un nouveau .env avec echo (méthode la plus sûre)
echo "PORT=3001" > .env
echo "NODE_ENV=production" >> .env
echo "DB_HOST=localhost" >> .env
echo "DB_USER=u133413376_root" >> .env
echo "DB_PASSWORD=Auxivie2025" >> .env
echo "DB_NAME=u133413376_auxivie" >> .env
echo "DB_PORT=3306" >> .env
echo "JWT_SECRET=une_cle_secrete_aleatoire" >> .env
echo "CORS_ORIGIN=https://www.auxivie.org" >> .env

# Vérifier
cat .env
```

### Vérifier qu'il n'y a pas d'espaces

```bash
# Voir les caractères invisibles
cat -A .env
```

Vous ne devriez voir que des `$` à la fin des lignes (retour à la ligne), pas d'espaces.

---

## 🔧 Solution 2 : Tester avec Valeurs Codées en Dur

Créez un fichier de test :

```bash
cd ~/backend/backend
nano test-hardcoded.js
```

Contenu :

```javascript
const mysql = require('mysql2/promise');

const config = {
  host: 'localhost',
  user: 'u133413376_root',
  password: 'Auxivie2025',
  database: 'u133413376_auxivie',
  port: 3306
};

(async () => {
  try {
    const conn = await mysql.createConnection(config);
    console.log('✅ Connexion réussie avec valeurs codées !');
    const [rows] = await conn.execute('SELECT 1 as test');
    console.log('✅ Requête testée:', rows);
    await conn.end();
    process.exit(0);
  } catch (error) {
    console.error('❌ Erreur:', error.message);
    console.error('Code:', error.code);
    process.exit(1);
  }
})();
```

Exécutez :

```bash
node test-hardcoded.js
```

**Si ça fonctionne** : Le problème vient du fichier `.env`

**Si ça échoue** : Le problème vient de MySQL (permissions, utilisateur, etc.)

---

## 🔧 Solution 3 : Vérifier les Permissions MySQL

Dans phpMyAdmin, onglet **"Privilèges"** :

1. Trouvez `u133413376_root@localhost`
2. Cliquez sur **"Modifier les privilèges"**
3. Vérifiez que pour la base `u133413376_auxivie` :
   - ✅ **"Tous les privilèges"** est coché
   - OU au minimum : SELECT, INSERT, UPDATE, DELETE, CREATE, ALTER, INDEX
4. Cliquez sur **"Exécuter"**

---

## 🔧 Solution 4 : Créer un Nouvel Utilisateur

Si rien ne fonctionne, créez un nouvel utilisateur dans phpMyAdmin :

1. **Onglet "Privilèges"** → **"Ajouter un compte d'utilisateur"**
2. Remplissez :
   - **Nom d'utilisateur** : `auxivie_api`
   - **Hôte** : `localhost`
   - **Mot de passe** : `Auxivie2025!`
   - **Confirmer** : `Auxivie2025!`
3. Dans **"Base de données pour la base de données spécifique"** :
   - Sélectionnez `u133413376_auxivie`
   - Cochez **"Tous les privilèges"**
4. Cliquez sur **"Exécuter"**

Puis mettez à jour `.env` :

```env
DB_USER=auxivie_api
DB_PASSWORD=Auxivie2025!
```

---

## 🧪 Tests à Effectuer

### Test 1 : MySQL Direct

```bash
mysql -u u133413376_root -pAuxivie2025 u133413376_auxivie -e "SELECT 1"
```

### Test 2 : Node.js avec valeurs codées

```bash
node test-hardcoded.js
```

### Test 3 : Node.js avec .env

```bash
node scripts/debug-mysql-connection.js
```

### Test 4 : Backend complet

```bash
npm start
```

---

## 📋 Checklist

- [ ] Fichier `.env` recréé proprement (sans espaces)
- [ ] Test MySQL direct réussi
- [ ] Test Node.js avec valeurs codées réussi
- [ ] Test Node.js avec .env réussi
- [ ] Privilèges vérifiés dans phpMyAdmin
- [ ] Backend démarre sans erreur

---

## 💡 Astuce

Si le test avec valeurs codées fonctionne mais pas avec `.env`, le problème vient du fichier `.env`. Utilisez `cat -A .env` pour voir les caractères invisibles.

---

**Commencez par exécuter `node scripts/debug-mysql-connection.js` pour voir exactement ce qui ne va pas !**

