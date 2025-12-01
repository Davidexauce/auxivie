#!/bin/bash

# Script de déploiement pour le backend
# Usage: ./scripts/deploy.sh [production|staging]

set -e

ENVIRONMENT=${1:-production}

echo "🚀 Déploiement du backend en mode: $ENVIRONMENT"

# Vérifier que les variables d'environnement sont définies
if [ ! -f ".env.$ENVIRONMENT" ]; then
    echo "❌ Erreur: Fichier .env.$ENVIRONMENT introuvable"
    exit 1
fi

# Installer les dépendances
echo "📦 Installation des dépendances..."
npm ci --only=production

# Créer les répertoires nécessaires
mkdir -p data logs

# Initialiser la base de données si nécessaire
echo "🗄️  Vérification de la base de données..."
node scripts/init-db.js

# Démarrer avec PM2
if command -v pm2 &> /dev/null; then
    echo "🔄 Démarrage avec PM2..."
    pm2 delete auxivie-backend 2>/dev/null || true
    pm2 start ecosystem.config.js --env $ENVIRONMENT
    pm2 save
    echo "✅ Backend démarré avec PM2"
else
    echo "⚠️  PM2 non installé. Installation recommandée: npm install -g pm2"
    echo "🔄 Démarrage avec node..."
    NODE_ENV=$ENVIRONMENT node server.js
fi

echo "✅ Déploiement terminé!"

