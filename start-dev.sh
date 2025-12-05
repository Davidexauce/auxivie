#!/bin/bash

# Script de démarrage rapide pour le mode développement
# Usage: ./start-dev.sh

echo "🚀 Démarrage du mode développement Auxivie"
echo ""

# Vérifier si Node.js est installé
if ! command -v node &> /dev/null; then
    echo "❌ Node.js n'est pas installé. Veuillez l'installer d'abord."
    exit 1
fi

# Vérifier si Flutter est installé
if ! command -v flutter &> /dev/null; then
    echo "⚠️  Flutter n'est pas installé. Vous devrez démarrer l'app manuellement."
fi

# Aller dans le dossier backend
cd backend

# Vérifier si node_modules existe
if [ ! -d "node_modules" ]; then
    echo "📦 Installation des dépendances backend..."
    npm install
fi

# Vérifier si le fichier .env existe
if [ ! -f ".env" ]; then
    echo "📝 Création du fichier .env..."
    cat > .env << EOF
PORT=3001
JWT_SECRET=dev-secret-key-$(openssl rand -hex 16)
STRIPE_SECRET_KEY=sk_test_placeholder
CORS_ORIGIN=http://localhost:3000,http://localhost:3001
NODE_ENV=development
EOF
    echo "✅ Fichier .env créé"
fi

# Vérifier si le dossier uploads existe
if [ ! -d "uploads" ]; then
    echo "📁 Création du dossier uploads..."
    mkdir -p uploads/documents uploads/photos
    echo "✅ Dossiers uploads créés"
fi

# Démarrer le backend
echo ""
echo "🔧 Démarrage du backend sur http://localhost:3001"
echo "   Appuyez sur Ctrl+C pour arrêter"
echo ""

npm run dev

