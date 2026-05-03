#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

BOARD="${1:-standalone}"
IMAGE_TARGET="${2:-orqa-image-core-dev}"

KAS_FILE="${ROOT_DIR}/kas/boards/${BOARD}.yml"
if [[ ! -f "${KAS_FILE}" ]]; then
  echo "Unknown board: ${BOARD}"
  exit 1
fi

if ! command -v kas >/dev/null 2>&1; then
  echo "kas is not installed or not on PATH"
  exit 1
fi

export KAS_WORK_DIR="${ROOT_DIR}/build/${BOARD}"
mkdir -p "${KAS_WORK_DIR}"

rm -rf "${KAS_WORK_DIR}/meta-orqa-builder"
rsync -a "${ROOT_DIR}/meta-orqa-builder/" "${KAS_WORK_DIR}/meta-orqa-builder/"

FETCH_CMD="bitbake ${IMAGE_TARGET} -c fetch"
SDK_CMD="bitbake ${IMAGE_TARGET} -c populate_sdk"

echo "Board: ${BOARD}"
echo "KAS file: ${KAS_FILE}"
echo "Work dir: ${KAS_WORK_DIR}"
echo "Fetch command: ${FETCH_CMD}"
echo "SDK command: ${SDK_CMD}"

kas shell "${KAS_FILE}" -c "${FETCH_CMD}"
kas shell "${KAS_FILE}" -c "${SDK_CMD}"

