#!/usr/bin/env bash
# Build export statique du dashboard + archive prête pour Hostinger (aidalia.auxivie.org).
# Usage : depuis la racine du dépôt Christelle Projet :
#   chmod +x scripts/deploy-aidalia-static.sh && ./scripts/deploy-aidalia-static.sh
#
# Déploiement : hPanel → Fichiers → dossier du domaine / sous-domaine aidalia
# → supprimer ou remplacer l’ancien _next/ → uploader TOUT le contenu extrait de l’archive
# (ou uploader tout le dossier admin-dashboard/out/ via FTP).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/admin-dashboard/out"
DIST="$ROOT/dist"
mkdir -p "$DIST"

cd "$ROOT/admin-dashboard"
export STATIC_EXPORT=1
rm -rf out .next
npm run build

STAMP=$(date +%Y%m%d-%H%M%S)
ARCHIVE="$DIST/aidalia-static-${STAMP}.tar.gz"
tar -czf "$ARCHIVE" -C "$OUT" .
echo ""
echo "=== OK ==="
echo "Dossier local : $OUT"
echo "Archive       : $ARCHIVE ($(du -h "$ARCHIVE" | awk '{print $1}'))"
echo ""
echo "Sur Hostinger : extraire l’archive à la racine web du site (écraser _next/, *.html, .htaccess)."
