#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BOARD="${1:-}"
OUT_DIR="${2:-${ROOT_DIR}/cache-seed/${BOARD}}"
BUILD_ROOT="${ROOT_DIR}/build/${BOARD}"
PART_SIZE="${PART_SIZE:-95m}"

if [[ -z "${BOARD}" ]]; then
  echo "Usage: $0 <apb|avp|evk|standalone> [out_dir]"
  exit 1
fi

mkdir -p "${OUT_DIR}"

bundle_dir() {
  local dir_name="$1"
  local source_dir="${BUILD_ROOT}/${dir_name}"
  local base="${OUT_DIR}/${dir_name}.tar.zst.part-"

  if [[ ! -d "${source_dir}" ]]; then
    echo "Skipping missing ${source_dir}"
    return 0
  fi

  rm -f "${OUT_DIR}/${dir_name}.tar.zst.part-"*
  tar --zstd -cf - -C "${BUILD_ROOT}" "${dir_name}" | split -b "${PART_SIZE}" -d -a 3 - "${base}"
}

bundle_dir downloads
bundle_dir sstate-cache

{
  echo "board=${BOARD}"
  echo "generated_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "part_size=${PART_SIZE}"
} > "${OUT_DIR}/manifest.txt"

