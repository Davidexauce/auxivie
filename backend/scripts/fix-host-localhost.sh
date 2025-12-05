#!/bin/bash

# Script pour changer DB_HOST de localhost à 127.0.0.1
# Utile si l'utilisateur MySQL existe pour 127.0.0.1 mais pas pour localhost

echo "🔧 Modification de DB_HOST dans .env..."
echo ""

ENV_FILE=".env"

if [ ! -f "$ENV_FILE" ]; then
    echo "❌ Erreur: Le fichier $ENV_FILE n'existe pas."
    exit 1
fi

# Sauvegarder
cp "$ENV_FILE" "${ENV_FILE}.backup-$(date +%Y%m%d-%H%M%S)"

# Remplacer localhost par 127.0.0.1
sed -i 's/^DB_HOST=localhost$/DB_HOST=127.0.0.1/' "$ENV_FILE"

# Vérifier
if grep -q "DB_HOST=127.0.0.1" "$ENV_FILE"; then
    echo "✅ DB_HOST modifié avec succès :"
    grep "DB_HOST" "$ENV_FILE"
    echo ""
    echo "💾 Sauvegarde créée : ${ENV_FILE}.backup-*"
    echo ""
    echo "🧪 Testez maintenant avec : npm start"
else
    echo "⚠️  DB_HOST n'a pas été modifié. Vérifiez le fichier .env manuellement."
    exit 1
fi

