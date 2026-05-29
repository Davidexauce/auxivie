#!/usr/bin/env bash
# Build du dashboard en fichiers statiques (dossier out/) pour Hostinger ou tout hébergeur sans Node.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
export STATIC_EXPORT=1
rm -rf out .next
npm run build
echo ""
echo "OK — déployez tout le contenu de :"
echo "  $ROOT/out/"
echo "vers le répertoire web du domaine (ex. public_html/aidalia), en écrasant les fichiers existants."
