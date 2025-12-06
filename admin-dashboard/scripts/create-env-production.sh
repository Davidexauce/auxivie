#!/bin/bash

# Script pour créer le fichier .env.production sur Hostinger
# Usage: bash create-env-production.sh

cat > .env.production << 'EOF'
# URL de l'API backend
NEXT_PUBLIC_API_URL=https://api.auxivie.org

# Environment
NODE_ENV=production
PORT=3000
EOF

echo "✅ Fichier .env.production créé !"
echo ""
echo "📋 Contenu:"
cat .env.production

