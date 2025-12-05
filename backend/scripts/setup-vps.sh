#!/bin/bash

# Script à exécuter SUR LE VPS après avoir uploadé les fichiers
# Usage: Sur le VPS, exécutez: bash setup-vps.sh

echo "🔧 Configuration du backend sur le VPS..."
echo ""

# Vérifier que nous sommes dans le bon dossier
if [ ! -f "server.js" ]; then
    echo "❌ Erreur: Ce script doit être exécuté depuis ~/backend/"
    exit 1
fi

# Créer les dossiers nécessaires
echo "📁 Création des dossiers..."
mkdir -p data
mkdir -p uploads/documents
mkdir -p uploads/photos
mkdir -p scripts
echo "✅ Dossiers créés"

# Vérifier Node.js
echo ""
echo "🔍 Vérification de Node.js..."
if ! command -v node &> /dev/null; then
    echo "❌ Node.js n'est pas installé"
    echo "📦 Installation de Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
else
    echo "✅ Node.js installé: $(node --version)"
fi

# Installer les dépendances
echo ""
echo "📦 Installation des dépendances..."
npm install --production
echo "✅ Dépendances installées"

# Vérifier le fichier .env
echo ""
if [ ! -f ".env" ]; then
    echo "⚠️  Fichier .env non trouvé"
    echo "📝 Création d'un fichier .env exemple..."
    cat > .env.example << EOF
# Port du serveur
PORT=3001

# Environnement
NODE_ENV=production

# Configuration MySQL
DB_HOST=auth-db1232.hstgr.io
DB_USER=u133413376_root
DB_PASSWORD=Auxivie2025
DB_NAME=u133413376_auxivie
DB_PORT=3306

# JWT Secret
JWT_SECRET=E9rT7yU6iO3pL8qW1aS2dF4gH5jK0lM

# CORS
CORS_ORIGIN=https://www.auxivie.org

# Stripe (optionnel)
STRIPE_SECRET_KEY=sk_test_votre_cle_stripe
EOF
    echo "✅ Fichier .env.example créé"
    echo "⚠️  IMPORTANT: Créez le fichier .env avec vos vraies valeurs !"
    echo "   Commande: cp .env.example .env && nano .env"
else
    echo "✅ Fichier .env trouvé"
fi

# Installer PM2 si pas installé
echo ""
if ! command -v pm2 &> /dev/null; then
    echo "📦 Installation de PM2..."
    npm install -g pm2
    echo "✅ PM2 installé"
else
    echo "✅ PM2 déjà installé"
fi

echo ""
echo "✅ Configuration terminée !"
echo ""
echo "📋 Prochaines étapes :"
echo "   1. Créer/modifier .env avec vos credentials MySQL"
echo "   2. Importer la base de données MySQL (si pas fait)"
echo "   3. Démarrer: pm2 start server.js --name auxivie-api"
echo "   4. Sauvegarder: pm2 save"
echo "   5. Vérifier: pm2 logs auxivie-api"
echo ""

