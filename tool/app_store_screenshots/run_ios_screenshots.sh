#!/usr/bin/env bash
# Lance les captures App Store sur un simulateur iOS (voir integration_test/app_store_screenshots_test.dart).
# Usage :
#   ./tool/app_store_screenshots/run_ios_screenshots.sh
#   ./tool/app_store_screenshots/run_ios_screenshots.sh "iPhone 16 Pro"
#   ./tool/app_store_screenshots/run_ios_screenshots.sh "Aidalya iPad"
#
# Ensuite, redimensionnez si besoin :
#   ./tool/app_store_screenshots/resize_for_app_store.sh portrait ./mes_png ./out_iphone67 iphone67

set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

NAME="${1:-iPhone 16 Pro}"
open -a Simulator 2>/dev/null || true

DEVICE_ID=$(xcrun simctl list devices available | grep -- "${NAME} (" | head -1 | sed -n 's/.*(\([A-F0-9-]*\)).*/\1/p' || true)
if [[ -z "${DEVICE_ID:-}" ]]; then
  echo "Simulateur introuvable : $NAME"
  echo "Exemples : xcrun simctl list devices available | grep -i iphone"
  exit 1
fi

echo "Boot $NAME ($DEVICE_ID)"
xcrun simctl boot "$DEVICE_ID" 2>/dev/null || true

echo "flutter test … -d $DEVICE_ID"
flutter test integration_test/app_store_screenshots_test.dart -d "$DEVICE_ID"

echo
echo "Les PNG sont généralement dans le répertoire de build / sortie du test."
echo "Recherche rapide : find \"$ROOT/build\" -name '*.png' 2>/dev/null | head -30"
find "$ROOT/build" -name '*.png' 2>/dev/null | head -30 || true
