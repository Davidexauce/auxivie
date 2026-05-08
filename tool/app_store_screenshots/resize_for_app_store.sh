#!/usr/bin/env bash
# Redimensionne des PNG pour App Store Connect (iPhone 6,5" / 6,7" et iPad 12,9").
# Usage :
#   chmod +x resize_for_app_store.sh
#   ./resize_for_app_store.sh portrait SOURCE_DIR DEST_DIR iphone67
#   ./resize_for_app_store.sh landscape SOURCE_DIR DEST_DIR iphone67
#   ./resize_for_app_store.sh portrait SOURCE_DIR DEST_DIR ipad129_2048
# Modes :
#   iphone65   → 1242 × 2688 (portrait) / 2688 × 1242 (paysage)
#   iphone67   → 1284 × 2778 (portrait) / 2778 × 1284 (paysage)
#   ipad129_2048 → 2048 × 2732 (portrait) / 2732 × 2048 (paysage)
#   ipad129_2064 → 2064 × 2752 (portrait) / 2752 × 2064 (paysage)

set -euo pipefail
ORIENTATION="${1:?orientation: portrait|landscape}"
SRC="${2:?dossier source}"
DST="${3:?dossier destination}"
MODE="${4:-iphone67}"

mkdir -p "$DST"

case "$MODE" in
  iphone65)
    PW=1242; PH=2688
    ;;
  iphone67)
    PW=1284; PH=2778
    ;;
  ipad129_2048)
    PW=2048; PH=2732
    ;;
  ipad129_2064)
    PW=2064; PH=2752
    ;;
  *)
    echo "Mode inconnu: $MODE"; exit 1
    ;;
esac

if [[ "$ORIENTATION" == "landscape" ]]; then
  H=$PW; W=$PH
else
  H=$PH; W=$PW
fi

shopt -s nullglob
for f in "$SRC"/*.png; do
  base=$(basename "$f")
  out="$DST/${base%.png}_${MODE}_${ORIENTATION}.png"
  sips -z "$H" "$W" "$f" --out "$out" >/dev/null
  echo "$out"
done

echo "Terminé → $DST"
