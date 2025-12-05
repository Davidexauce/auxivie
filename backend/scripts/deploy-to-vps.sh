#!/bin/bash

# Script pour déployer le backend sur le VPS Hostinger
# Usage: ./deploy-to-vps.sh

VPS_USER="apiuser"
VPS_HOST="178.16.131.24"
VPS_PATH="~/backend"

echo "🚀 Déploiement du backend sur VPS Hostinger..."
echo ""

# Vérifier que nous sommes dans le bon dossier
if [ ! -f "server.js" ]; then
    echo "❌ Erreur: Ce script doit être exécuté depuis le dossier backend/"
    exit 1
fi

echo "📦 Préparation des fichiers..."
echo ""

# Créer une archive temporaire
TEMP_DIR=$(mktemp -d)
echo "📁 Dossier temporaire: $TEMP_DIR"

# Copier les fichiers essentiels
echo "📋 Copie des fichiers..."
cp server.js "$TEMP_DIR/"
cp package.json "$TEMP_DIR/"
cp package-lock.json "$TEMP_DIR/" 2>/dev/null || echo "⚠️  package-lock.json non trouvé"
cp db.js "$TEMP_DIR/"
cp -r scripts "$TEMP_DIR/" 2>/dev/null || echo "⚠️  scripts/ non trouvé"

echo ""
echo "📤 Upload des fichiers vers le VPS..."
echo ""

# Uploader les fichiers via SCP
scp "$TEMP_DIR/server.js" "$VPS_USER@$VPS_HOST:$VPS_PATH/"
scp "$TEMP_DIR/package.json" "$VPS_USER@$VPS_HOST:$VPS_PATH/"
[ -f "$TEMP_DIR/package-lock.json" ] && scp "$TEMP_DIR/package-lock.json" "$VPS_USER@$VPS_HOST:$VPS_PATH/"
scp "$TEMP_DIR/db.js" "$VPS_USER@$VPS_HOST:$VPS_PATH/"
[ -d "$TEMP_DIR/scripts" ] && scp -r "$TEMP_DIR/scripts" "$VPS_USER@$VPS_HOST:$VPS_PATH/"

# Nettoyer
rm -rf "$TEMP_DIR"

echo ""
echo "✅ Fichiers uploadés !"
echo ""
echo "📋 Prochaines étapes sur le VPS :"
echo "   1. Se connecter: ssh $VPS_USER@$VPS_HOST"
echo "   2. Aller dans: cd ~/backend"
echo "   3. Créer .env avec les credentials MySQL"
echo "   4. Exécuter: npm install --production"
echo "   5. Démarrer: pm2 start server.js --name auxivie-api"
echo ""

