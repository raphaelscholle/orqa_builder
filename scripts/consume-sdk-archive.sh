#!/usr/bin/env bash
set -euo pipefail

ARCHIVE_DIR="${1:-}"
DEST_DIR="${2:-}"

if [[ -z "${ARCHIVE_DIR}" || -z "${DEST_DIR}" ]]; then
  echo "Usage: $0 <archive_dir> <dest_dir>"
  exit 1
fi

mkdir -p "${DEST_DIR}"
cat "${ARCHIVE_DIR}"/sdk-bundle.tar.zst.part-* | tar --zstd -xf - -C "${DEST_DIR}"

find "${DEST_DIR}" -maxdepth 2 -type f -name 'environment-setup-*' | sort

