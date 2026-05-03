#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BOARD="${1:-}"
SEED_DIR="${2:-${ROOT_DIR}/cache-seed-download/${BOARD}}"
BUILD_ROOT="${ROOT_DIR}/build/${BOARD}"

if [[ -z "${BOARD}" ]]; then
  echo "Usage: $0 <apb|avp|evk|standalone> [seed_dir]"
  exit 1
fi

mkdir -p "${BUILD_ROOT}"

restore_parts() {
  local prefix="$1"
  local target_dir="$2"
  if compgen -G "${SEED_DIR}/${prefix}.tar.zst.part-*" > /dev/null; then
    mkdir -p "${target_dir}"
    cat "${SEED_DIR}/${prefix}.tar.zst.part-"* | tar --zstd -xf - -C "${BUILD_ROOT}"
  fi
}

restore_parts downloads "${BUILD_ROOT}/downloads"
restore_parts sstate-cache "${BUILD_ROOT}/sstate-cache"

