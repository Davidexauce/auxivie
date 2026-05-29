#!/usr/bin/env bash
# Déploie le dossier « landing page » vers le serveur (rsync).
# Prérequis : clé SSH configurée pour l’utilisateur distant.
#
# Usage :
#   export LANDING_DEPLOY_SSH="root@VOTRE_IP"
#   export LANDING_DEPLOY_PATH="/var/www/auxivie-landing"
#   bash tool/deploy_landing.sh
#
# Port SSH non standard (ex. Hostinger 65002) :
#   export LANDING_DEPLOY_PORT="65002"
#
# Si LANDING_DEPLOY_PATH est vide, la valeur par défaut est /var/www/auxivie-landing

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="${ROOT}/landing page"

if [[ ! -f "${SRC}/index.html" ]]; then
  echo "Erreur : dossier source introuvable : ${SRC}"
  exit 1
fi

REMOTE="${LANDING_DEPLOY_SSH:-}"
REMOTE_PATH="${LANDING_DEPLOY_PATH:-/var/www/auxivie-landing}"
SSH_PORT="${LANDING_DEPLOY_PORT:-}"

RSYNC_SSH=(ssh)
if [[ -n "${SSH_PORT}" ]]; then
  RSYNC_SSH+=(-p "${SSH_PORT}")
fi

if [[ -z "${REMOTE}" ]]; then
  echo "Définissez LANDING_DEPLOY_SSH, par exemple :"
  echo "  export LANDING_DEPLOY_SSH=\"root@178.x.x.x\""
  exit 1
fi

echo "→ rsync vers ${REMOTE}:${REMOTE_PATH}/"
rsync -avz --delete \
  --exclude '.DS_Store' \
  -e "${RSYNC_SSH[*]}" \
  "${SRC}/" "${REMOTE}:${REMOTE_PATH}/"

echo "Terminé. Vérifiez https://auxivie.org/ (rafraîchissement fort si besoin)."
