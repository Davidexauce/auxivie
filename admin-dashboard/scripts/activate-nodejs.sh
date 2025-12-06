#!/bin/bash

# Script pour activer Node.js sur Hostinger
# Usage: source activate-nodejs.sh

echo "🔧 Activation de Node.js sur Hostinger..."
echo ""

# Chemins Node.js disponibles
NODEJS18_PATH="/opt/alt/alt-nodejs18/root/usr"
NODEJS20_PATH="/opt/alt/alt-nodejs20/root/usr"
NODEJS22_PATH="/opt/alt/alt-nodejs22/root/usr"
NODEJS24_PATH="/opt/alt/alt-nodejs24/root/usr"

# Utiliser Node.js 18 par défaut (ou 20 si 18 n'existe pas)
if [ -f "$NODEJS18_PATH/bin/node" ]; then
    NODEJS_PATH="$NODEJS18_PATH"
    echo "✅ Utilisation de Node.js 18"
elif [ -f "$NODEJS20_PATH/bin/node" ]; then
    NODEJS_PATH="$NODEJS20_PATH"
    echo "✅ Utilisation de Node.js 20"
elif [ -f "$NODEJS22_PATH/bin/node" ]; then
    NODEJS_PATH="$NODEJS22_PATH"
    echo "✅ Utilisation de Node.js 22"
else
    NODEJS_PATH="$NODEJS24_PATH"
    echo "✅ Utilisation de Node.js 24"
fi

# Ajouter au PATH
export PATH="$NODEJS_PATH/bin:$PATH"

# Vérifier
echo ""
echo "📋 Vérification:"
node --version
npm --version

echo ""
echo "✅ Node.js activé !"
echo "💡 Pour utiliser dans cette session, exécutez: source activate-nodejs.sh"
echo "💡 Ou utilisez directement: $NODEJS_PATH/bin/node et $NODEJS_PATH/bin/npm"

