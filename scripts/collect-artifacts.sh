#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BOARD="${1:-}"

if [[ -z "${BOARD}" ]]; then
  echo "Usage: $0 <apb|avp|evk|standalone>"
  exit 1
fi

DEPLOY_DIR="${ROOT_DIR}/build/${BOARD}/build/tmp/deploy"
DEB_DIR="${DEPLOY_DIR}/deb"
OUT_DIR="${ROOT_DIR}/artifacts/${BOARD}"

mkdir -p "${OUT_DIR}"

if [[ ! -d "${DEB_DIR}" ]]; then
  echo "No deploy deb directory found at ${DEB_DIR}"
  exit 1
fi

mkdir -p "${OUT_DIR}/deb"
rsync -a --prune-empty-dirs \
  --include '*/' \
  --include '*.deb' \
  --exclude '*' \
  "${DEB_DIR}/" "${OUT_DIR}/deb/"

{
  echo "board=${BOARD}"
  echo "generated_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "deploy_dir=${DEPLOY_DIR}"
  echo "deb_count=$(find "${OUT_DIR}/deb" -type f -name '*.deb' | wc -l)"
} > "${OUT_DIR}/build-metadata.txt"

find "${OUT_DIR}" -type f | sort
