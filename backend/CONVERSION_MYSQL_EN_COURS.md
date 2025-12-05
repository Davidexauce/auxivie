# ⚠️ Conversion MySQL en cours

## Statut

Le fichier `server.js` est en cours de conversion de SQLite vers MySQL.

### ✅ Fait
- Module `db.js` créé avec connexion MySQL
- `mysql2` installé
- Routes principales converties (login, users)
- `datetime("now")` remplacé par `NOW()`

### ⏳ À faire
- Convertir toutes les routes restantes de callback vers async/await
- Tester toutes les routes
- Mettre à jour les variables d'environnement

## Routes restantes à convertir

Il reste environ 50+ routes à convertir. Le processus est en cours.

## Note

Le fichier peut avoir des erreurs temporaires pendant la conversion. Ne pas utiliser en production tant que la conversion n'est pas terminée.

