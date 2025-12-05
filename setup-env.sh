#!/bin/bash

# Script pour créer les fichiers d'environnement
# Usage: ./setup-env.sh

echo "🔧 Configuration des fichiers d'environnement..."

# Backend
if [ ! -f "backend/.env.example" ]; then
    echo "📝 Création de backend/.env.example..."
    cat > backend/.env.example << 'EOF'
# Configuration Backend - Exemple
NODE_ENV=development
PORT=3001
JWT_SECRET=your-secret-key-change-in-production
DB_PATH=./data/auxivie.db
CORS_ORIGIN=http://localhost:3000,http://localhost:3001
API_URL=http://localhost:3001
EOF
fi

if [ ! -f "backend/.env.production" ]; then
    echo "📝 Création de backend/.env.production..."
    cat > backend/.env.production << 'EOF'
# Configuration Backend - PRODUCTION
# ⚠️ NE COMMITEZ JAMAIS CE FICHIER AVEC DES VRAIES VALEURS !
NODE_ENV=production
PORT=3001
JWT_SECRET=CHANGEZ-CE-SECRET-EN-PRODUCTION-GENEREZ-UN-SECRET-FORT
DB_PATH=./data/auxivie.db
CORS_ORIGIN=https://votre-dashboard.com,https://api.votre-domaine.com
API_URL=https://api.votre-domaine.com
EOF
    echo "⚠️  N'oubliez pas de générer un JWT_SECRET fort : openssl rand -base64 32"
fi

# Dashboard
if [ ! -f "admin-dashboard/.env.example" ]; then
    echo "📝 Création de admin-dashboard/.env.example..."
    cat > admin-dashboard/.env.example << 'EOF'
# Configuration Dashboard - Exemple
NEXT_PUBLIC_API_URL=http://localhost:3001
NODE_ENV=development
EOF
fi

if [ ! -f "admin-dashboard/.env.production" ]; then
    echo "📝 Création de admin-dashboard/.env.production..."
    cat > admin-dashboard/.env.production << 'EOF'
# Configuration Dashboard - PRODUCTION
# ⚠️ NE COMMITEZ JAMAIS CE FICHIER AVEC DES VRAIES VALEURS !
NEXT_PUBLIC_API_URL=https://api.votre-domaine.com
NODE_ENV=production
EOF
fi

echo ""
echo "✅ Fichiers d'environnement créés !"
echo ""
echo "📝 Prochaines étapes :"
echo "  1. Éditez backend/.env.production avec vos valeurs"
echo "  2. Éditez admin-dashboard/.env.production avec vos valeurs"
echo "  3. Générez un JWT_SECRET : openssl rand -base64 32"
echo "  4. Configurez vos domaines dans les fichiers .env"

