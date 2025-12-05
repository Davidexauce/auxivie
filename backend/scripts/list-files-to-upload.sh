#!/bin/bash

# Script pour lister tous les fichiers à uploader sur Hostinger

echo "📋 Liste des fichiers à uploader sur Hostinger"
echo "================================================"
echo ""

BACKEND_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "📍 Dossier source: $BACKEND_DIR"
echo ""

echo "📁 FICHIERS À UPLOADER DANS: domains/auxivie.org/backend/"
echo ""

# Fichiers à la racine du backend
echo "📄 Fichiers racine:"
echo "   - server.js"
echo "   - package.json"
[ -f "$BACKEND_DIR/package-lock.json" ] && echo "   - package-lock.json"
echo ""

# Dossier scripts
if [ -d "$BACKEND_DIR/scripts" ]; then
    echo "📂 Dossier scripts/ (uploader tout le dossier):"
    find "$BACKEND_DIR/scripts" -type f -name "*.js" | while read file; do
        rel_path=${file#$BACKEND_DIR/}
        echo "   - $rel_path"
    done
    echo ""
fi

# Base de données
echo "💾 Base de données à uploader dans: backend/data/"
if [ -f "$BACKEND_DIR/data/auxivie.db" ]; then
    SIZE=$(du -h "$BACKEND_DIR/data/auxivie.db" | cut -f1)
    echo "   - auxivie.db ($SIZE)"
else
    echo "   ⚠️  auxivie.db non trouvé !"
fi
echo ""

# Fichier .env à créer
echo "⚙️  Fichier .env à créer manuellement dans: backend/"
echo "   (Voir GUIDE_RAPIDE_BACKEND.md pour le contenu)"
echo ""

# Structure des dossiers
echo "📁 Dossiers à créer dans: domains/auxivie.org/backend/"
echo "   - data/"
echo "   - uploads/"
echo "   - uploads/documents/"
echo "   - uploads/photos/"
echo ""

echo "✅ Liste complète !"
echo ""
echo "💡 Astuce: Utilisez le glisser-déposer dans le File Manager de Hostinger"
echo ""

