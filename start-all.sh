#!/bin/bash

# Script pour démarrer tous les serveurs (Backend + Dashboard)
# Usage: ./start-all.sh

echo "🚀 Démarrage de tous les serveurs Auxivie"
echo ""

# Fonction pour nettoyer les processus à l'arrêt
cleanup() {
    echo ""
    echo "🛑 Arrêt des serveurs..."
    kill $BACKEND_PID $DASHBOARD_PID 2>/dev/null
    exit
}

trap cleanup SIGINT SIGTERM

# Vérifier si Node.js est installé
if ! command -v node &> /dev/null; then
    echo "❌ Node.js n'est pas installé. Veuillez l'installer d'abord."
    exit 1
fi

# ========== BACKEND ==========
echo "📦 Configuration du backend..."
cd backend

# Vérifier si node_modules existe
if [ ! -d "node_modules" ]; then
    echo "   Installation des dépendances backend..."
    npm install
fi

# Vérifier si le fichier .env existe
if [ ! -f ".env" ]; then
    echo "   Création du fichier .env..."
    cat > .env << EOF
PORT=3001
JWT_SECRET=dev-secret-key-$(openssl rand -hex 16)
STRIPE_SECRET_KEY=sk_test_placeholder
CORS_ORIGIN=http://localhost:3000,http://localhost:3001
NODE_ENV=development
EOF
    echo "   ✅ Fichier .env créé"
fi

# Vérifier si le dossier uploads existe
if [ ! -d "uploads" ]; then
    echo "   Création du dossier uploads..."
    mkdir -p uploads/documents uploads/photos
    echo "   ✅ Dossiers uploads créés"
fi

# Démarrer le backend
echo ""
echo "🔧 Démarrage du backend sur http://localhost:3001"
npm run dev > ../logs/backend.log 2>&1 &
BACKEND_PID=$!

# Attendre que le backend démarre
sleep 3

# Vérifier si le backend est démarré
if ! kill -0 $BACKEND_PID 2>/dev/null; then
    echo "❌ Erreur lors du démarrage du backend"
    exit 1
fi

echo "   ✅ Backend démarré (PID: $BACKEND_PID)"
echo ""

# ========== DASHBOARD ==========
cd ../admin-dashboard

echo "📦 Configuration du dashboard..."
# Vérifier si node_modules existe
if [ ! -d "node_modules" ]; then
    echo "   Installation des dépendances dashboard..."
    npm install
fi

# Vérifier si le fichier .env.local existe
if [ ! -f ".env.local" ]; then
    echo "   Création du fichier .env.local..."
    cat > .env.local << EOF
NEXT_PUBLIC_API_URL=http://localhost:3001
EOF
    echo "   ✅ Fichier .env.local créé"
fi

# Démarrer le dashboard
echo ""
echo "🎨 Démarrage du dashboard sur http://localhost:3000"
npm run dev > ../logs/dashboard.log 2>&1 &
DASHBOARD_PID=$!

# Attendre que le dashboard démarre
sleep 3

# Vérifier si le dashboard est démarré
if ! kill -0 $DASHBOARD_PID 2>/dev/null; then
    echo "❌ Erreur lors du démarrage du dashboard"
    kill $BACKEND_PID 2>/dev/null
    exit 1
fi

echo "   ✅ Dashboard démarré (PID: $DASHBOARD_PID)"
echo ""

# Créer le dossier logs s'il n'existe pas
mkdir -p ../logs

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Tous les serveurs sont démarrés !"
echo ""
echo "📍 Backend API:    http://localhost:3001"
echo "📍 Dashboard:      http://localhost:3000"
echo ""
echo "📝 Logs:"
echo "   - Backend:   tail -f logs/backend.log"
echo "   - Dashboard: tail -f logs/dashboard.log"
echo ""
echo "🛑 Appuyez sur Ctrl+C pour arrêter tous les serveurs"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Attendre que les processus se terminent
wait

