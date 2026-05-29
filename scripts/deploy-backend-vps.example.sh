#!/usr/bin/env bash
# Exemple : copier le backend sur le VPS puis redémarrer PM2.
# Copier ce fichier en deploy-backend-vps.sh, renseigner VPS_USER et VPS_PATH, puis :
#   chmod +x deploy-backend-vps.sh && ./deploy-backend-vps.sh
#
# Prérequis : clé SSH acceptée sur le serveur (voir docs/DEPLOYMENT.md).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VPS_USER="${VPS_USER:-root}"
VPS_HOST="${VPS_HOST:-178.16.131.24}"
VPS_PATH="${VPS_PATH:-/root/auxivie/backend}"

rsync -avz --delete \
  --exclude node_modules \
  --exclude .env \
  --exclude .env.production \
  --exclude uploads \
  "$ROOT/backend/" "${VPS_USER}@${VPS_HOST}:${VPS_PATH}/"

ssh "${VPS_USER}@${VPS_HOST}" "cd ${VPS_PATH} && npm ci --omit=dev && pm2 restart api --update-env"
