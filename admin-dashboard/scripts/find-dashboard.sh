#!/bin/bash

# Script pour trouver le Dashboard sur Hostinger
echo "🔍 Recherche du Dashboard..."
echo ""

# 1. Vérifier public_html
echo "1. Contenu de public_html:"
if [ -d ~/domains/auxivie.org/public_html ]; then
    ls -la ~/domains/auxivie.org/public_html/
    echo ""
else
    echo "   ❌ Dossier public_html non trouvé"
    echo ""
fi

# 2. Chercher les dossiers avec "admin" ou "dashboard"
echo "2. Dossiers contenant 'admin' ou 'dashboard':"
find ~/domains/auxivie.org/public_html -type d \( -iname "*admin*" -o -iname "*dashboard*" \) 2>/dev/null | head -10
echo ""

# 3. Chercher next.config.js
echo "3. Fichiers next.config.js trouvés:"
find ~/domains/auxivie.org/public_html -name "next.config.js" 2>/dev/null
echo ""

# 4. Chercher package.json avec "next"
echo "4. Fichiers package.json contenant 'next':"
find ~/domains/auxivie.org/public_html -name "package.json" -exec grep -l "next" {} \; 2>/dev/null
echo ""

# 5. Chercher dans tout le home
echo "5. Recherche dans tout le home (~):"
find ~ -maxdepth 5 -name "next.config.js" 2>/dev/null | grep -v node_modules | head -5
echo ""

# 6. Chercher package.json avec "auxivie-admin"
echo "6. Fichiers package.json avec 'auxivie-admin':"
find ~ -maxdepth 5 -name "package.json" -exec grep -l "auxivie-admin" {} \; 2>/dev/null | grep -v node_modules | head -5
echo ""

# 7. Vérifier la structure complète de public_html
echo "7. Structure complète de public_html (maxdepth 3):"
find ~/domains/auxivie.org/public_html -maxdepth 3 -type d 2>/dev/null
echo ""

echo "✅ Recherche terminée"
echo ""
echo "💡 Si aucun résultat, le Dashboard n'est peut-être pas encore déployé."

