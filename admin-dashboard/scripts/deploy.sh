#!/bin/bash

# Script de déploiement pour le Dashboard
# Usage: ./scripts/deploy.sh [production|staging]

set -e

ENVIRONMENT=${1:-production}

echo "🚀 Déploiement du Dashboard en mode: $ENVIRONMENT"

# Vérifier que les variables d'environnement sont définies
if [ ! -f ".env.$ENVIRONMENT" ]; then
    echo "❌ Erreur: Fichier .env.$ENVIRONMENT introuvable"
    exit 1
fi

# Installer les dépendances
echo "📦 Installation des dépendances..."
npm ci

# Build de production
echo "🔨 Build de production..."
npm run build

# Démarrer le serveur
echo "🚀 Démarrage du serveur..."
npm start

echo "✅ Déploiement terminé!"

