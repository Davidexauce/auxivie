#!/bin/bash

# Script pour ouvrir le dossier de la base de données dans le Finder
# pour faciliter l'upload sur Hostinger

DB_DIR="$(cd "$(dirname "$0")/../data" && pwd)"

echo "📂 Ouverture du dossier dans le Finder..."
echo "   Chemin: $DB_DIR"
echo ""
echo "📋 Prochaines étapes:"
echo "   1. Le Finder va s'ouvrir avec le fichier auxivie.db"
echo "   2. Ouvrez le File Manager de Hostinger"
echo "   3. Naviguez vers: backend/data/"
echo "   4. Glissez-déposez auxivie.db dans le File Manager"
echo "   5. Configurez les permissions à 644 ou 666"
echo "   6. Redémarrez le backend Node.js"
echo ""

# Ouvrir le dossier dans le Finder
open "$DB_DIR"

# Attendre 1 seconde puis sélectionner le fichier
sleep 1
open -R "$DB_DIR/auxivie.db"

echo "✅ Finder ouvert !"
echo "   Fichier à uploader: auxivie.db (80 KB)"
echo ""

