#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

BOARD="${1:-}"
TARGET_SET="${2:-all}"
shift "$(( $# > 0 ? 1 : 0 ))" || true
shift "$(( $# > 0 ? 1 : 0 ))" || true

if [[ -z "${BOARD}" ]]; then
  echo "Usage: $0 <apb|avp|evk|standalone> <openhd-runtime|openhd-stack|kernel|all|custom> [custom recipe names...]"
  exit 1
fi

KAS_FILE="${ROOT_DIR}/kas/boards/${BOARD}.yml"
if [[ ! -f "${KAS_FILE}" ]]; then
  echo "Unknown board: ${BOARD}"
  exit 1
fi

case "${TARGET_SET}" in
  openhd-runtime)
    TARGETS=(openhd openhd-sys-utils)
    ;;
  openhd-stack)
    TARGETS=(openhd qopenhd openhd-sys-utils)
    ;;
  kernel)
    TARGETS=(linux-imx)
    ;;
  all)
    TARGETS=(openhd qopenhd openhd-sys-utils linux-imx)
    ;;
  custom)
    if [[ "$#" -eq 0 ]]; then
      echo "Custom mode requires at least one BitBake recipe name"
      exit 1
    fi
    TARGETS=("$@")
    ;;
  *)
    echo "Unknown target set: ${TARGET_SET}"
    exit 1
    ;;
esac

if ! command -v kas >/dev/null 2>&1; then
  echo "kas is not installed or not on PATH"
  exit 1
fi

export KAS_WORK_DIR="${ROOT_DIR}/build/${BOARD}"
mkdir -p "${KAS_WORK_DIR}"

# Keep source/download/sstate reuse, but force BitBake to regenerate config and
# metadata decisions on every CI run. Otherwise stale local.conf/cache can keep
# scheduling recipes that newer builder settings mask out.
rm -rf \
  "${KAS_WORK_DIR}/build/conf" \
  "${KAS_WORK_DIR}/build/cache" \
  "${KAS_WORK_DIR}/build/bitbake-cookerdaemon.log" \
  "${KAS_WORK_DIR}/build/hashserve.sock" \
  "${KAS_WORK_DIR}/build/tmp/cache"

# kas resolves local non-VCS repo paths relative to the active work tree.
# Stage the overlay layer into that work tree so bblayers can resolve it.
rm -rf "${KAS_WORK_DIR}/meta-orqa-builder"
rsync -a "${ROOT_DIR}/meta-orqa-builder/" "${KAS_WORK_DIR}/meta-orqa-builder/"

BITBAKE_CMD="bitbake ${TARGETS[*]} -c package_write_deb"
FETCH_CMD="bitbake ${TARGETS[*]} -c fetch"

echo "Board: ${BOARD}"
echo "KAS file: ${KAS_FILE}"
echo "Work dir: ${KAS_WORK_DIR}"
echo "Fetch command: ${FETCH_CMD}"
echo "Command: ${BITBAKE_CMD}"

kas shell "${KAS_FILE}" -c "${FETCH_CMD}"
kas shell "${KAS_FILE}" -c "${BITBAKE_CMD}"

if [[ "${TARGET_SET}" != "kernel" ]]; then
  kas shell "${KAS_FILE}" -c "bitbake package-index"
fi
