#!/bin/bash

# Script pour pousser le projet sur GitHub
# Usage: ./push-to-github.sh [token]

set -e

cd "$(dirname "$0")"

echo "🚀 Poussage du projet Auxivie sur GitHub..."
echo ""

# Vérifier si un token est fourni en argument
if [ -n "$1" ]; then
    TOKEN="$1"
    echo "✅ Utilisation du token fourni"
    git push https://${TOKEN}@github.com/Davidexauce/auxivie.git master
elif [ -n "$GITHUB_TOKEN" ]; then
    echo "✅ Utilisation du token depuis la variable d'environnement GITHUB_TOKEN"
    git push https://${GITHUB_TOKEN}@github.com/Davidexauce/auxivie.git master
else
    echo "❌ Aucun token fourni"
    echo ""
    echo "Options pour pousser sur GitHub:"
    echo ""
    echo "1. Avec un token (recommandé):"
    echo "   ./push-to-github.sh VOTRE_TOKEN"
    echo ""
    echo "2. Avec variable d'environnement:"
    echo "   export GITHUB_TOKEN=votre_token"
    echo "   ./push-to-github.sh"
    echo ""
    echo "3. Configuration SSH:"
    echo "   git remote set-url origin git@github.com:Davidexauce/auxivie.git"
    echo "   git push origin master"
    echo ""
    echo "4. Créer un token GitHub:"
    echo "   https://github.com/settings/tokens"
    echo ""
    exit 1
fi

echo ""
echo "✅ Push réussi !"
echo "📦 Dépôt: https://github.com/Davidexauce/auxivie"

