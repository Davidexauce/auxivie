#!/bin/bash

# Script pour vérifier le fichier .env
# Usage: bash scripts/verify-env.sh

echo "🔍 Vérification du fichier .env..."
echo ""

if [ ! -f ".env" ]; then
    echo "❌ Fichier .env non trouvé"
    exit 1
fi

echo "✅ Fichier .env trouvé"
echo ""

# Vérifier les variables MySQL
echo "📋 Variables MySQL:"
echo ""

DB_HOST=$(grep "^DB_HOST=" .env | cut -d '=' -f2 | tr -d ' ')
DB_USER=$(grep "^DB_USER=" .env | cut -d '=' -f2 | tr -d ' ')
DB_PASSWORD=$(grep "^DB_PASSWORD=" .env | cut -d '=' -f2 | tr -d ' ')
DB_NAME=$(grep "^DB_NAME=" .env | cut -d '=' -f2 | tr -d ' ')
DB_PORT=$(grep "^DB_PORT=" .env | cut -d '=' -f2 | tr -d ' ')

echo "  DB_HOST: '$DB_HOST'"
echo "  DB_USER: '$DB_USER'"
echo "  DB_PASSWORD: '${DB_PASSWORD:0:3}***' (masqué)"
echo "  DB_NAME: '$DB_NAME'"
echo "  DB_PORT: '$DB_PORT'"
echo ""

# Vérifier les espaces
echo "🔍 Vérification des espaces..."
if grep -q "^DB_.*= " .env || grep -q "^DB_.*=  " .env; then
    echo "⚠️  Espaces détectés après le ="
    echo "   Corrigez: DB_USER=value (pas DB_USER= value)"
fi

if grep -q "^DB_.* = " .env; then
    echo "⚠️  Espaces détectés avant le ="
    echo "   Corrigez: DB_USER=value (pas DB_USER =value)"
fi

# Vérifier les guillemets
if grep -q "^DB_.*='.*'" .env || grep -q '^DB_.*=".*"' .env; then
    echo "⚠️  Guillemets détectés dans les valeurs"
    echo "   Retirez les guillemets: DB_USER=value (pas DB_USER='value')"
fi

# Afficher le contenu exact
echo ""
echo "📄 Contenu exact du fichier .env (lignes DB_*):"
grep "^DB_" .env | cat -A

echo ""
echo "✅ Vérification terminée"

