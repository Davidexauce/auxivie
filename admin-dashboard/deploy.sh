#!/bin/bash
# Script de déploiement pour Auxivie Admin Dashboard

echo "🚀 Déploiement du dashboard admin..."

# 1. Build Next.js
echo "📦 Construction du projet..."
npm run build

# 2. Copier les fichiers statiques dans standalone
echo "📋 Copie des fichiers statiques..."
cp -r .next/static .next/standalone/admin-dashboard/.next/
cp -r public .next/standalone/admin-dashboard/ 2>/dev/null || true

# 3. Redémarrer PM2
echo "🔄 Redémarrage du serveur..."
pm2 restart admin-dashboard

echo "✅ Déploiement terminé !"
pm2 status
