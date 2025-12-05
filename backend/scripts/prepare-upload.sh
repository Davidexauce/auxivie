#!/bin/bash

# Script pour préparer l'upload de la base de données sur Hostinger

echo "📦 Préparation de l'upload de la base de données..."
echo ""

# Chemin de la base de données
DB_PATH="data/auxivie.db"
BACKUP_DIR="backups"

# Vérifier que le fichier existe
if [ ! -f "$DB_PATH" ]; then
    echo "❌ Erreur: Le fichier $DB_PATH n'existe pas"
    exit 1
fi

# Créer le dossier backups s'il n'existe pas
mkdir -p "$BACKUP_DIR"

# Créer une sauvegarde avec timestamp
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_FILE="$BACKUP_DIR/auxivie-backup-$TIMESTAMP.db"

echo "💾 Création d'une sauvegarde..."
cp "$DB_PATH" "$BACKUP_FILE"

# Afficher les informations
FILE_SIZE=$(du -h "$DB_PATH" | cut -f1)
echo ""
echo "✅ Fichier prêt pour l'upload:"
echo "   📁 Chemin: $DB_PATH"
echo "   📊 Taille: $FILE_SIZE"
echo "   💾 Sauvegarde: $BACKUP_FILE"
echo ""
echo "📋 Instructions pour l'upload:"
echo "   1. Ouvrir le File Manager dans Hostinger"
echo "   2. Naviguer vers: domains/auxivie.org/backend/data/"
echo "   3. Uploader le fichier: $DB_PATH"
echo "   4. Configurer les permissions à 644 ou 666"
echo "   5. Redémarrer le backend Node.js"
echo ""

