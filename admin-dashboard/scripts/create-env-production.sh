#!/bin/bash

# Script pour créer le fichier .env.production sur Hostinger
# Usage: Exécutez ce script sur Hostinger ou copiez le contenu dans le terminal Hostinger

echo "📝 Création du fichier .env.production pour le Dashboard..."
echo ""

# Chemin du dossier admin-dashboard
DASHBOARD_DIR="~/domains/auxivie.org/public_html/admin-dashboard"

# Vérifier si nous sommes dans le bon dossier
if [ -f "package.json" ] && [ -f "next.config.js" ]; then
    DASHBOARD_DIR="."
    echo "✅ Détection automatique du dossier admin-dashboard"
else
    echo "📁 Utilisation du chemin: $DASHBOARD_DIR"
    echo "💡 Si vous êtes dans un autre dossier, modifiez DASHBOARD_DIR dans le script"
fi

# Contenu du fichier
ENV_CONTENT="NEXT_PUBLIC_API_URL=https://api.auxivie.org"

# Créer le fichier
if [ "$DASHBOARD_DIR" = "." ]; then
    ENV_FILE=".env.production"
else
    ENV_FILE="$DASHBOARD_DIR/.env.production"
fi

echo "$ENV_CONTENT" > "$ENV_FILE"

# Vérifier que le fichier a été créé
if [ -f "$ENV_FILE" ]; then
    echo "✅ Fichier créé avec succès: $ENV_FILE"
    echo ""
    echo "📋 Contenu du fichier:"
    cat "$ENV_FILE"
    echo ""
    echo "🔄 Prochaines étapes:"
    echo "   1. Vérifiez le contenu ci-dessus"
    echo "   2. Rebuild le Dashboard: npm run build"
    echo "   3. Redémarrez le serveur: npm start"
else
    echo "❌ Erreur: Le fichier n'a pas pu être créé"
    echo "💡 Vérifiez les permissions du dossier"
    exit 1
fi

