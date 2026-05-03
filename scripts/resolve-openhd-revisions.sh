#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

fetch_head() {
  local url="$1"
  local ref="$2"
  git ls-remote "${url}" "${ref}" | awk '{print $1}'
}

OPENHD_SHA="$(fetch_head https://github.com/OpenHD/OpenHD.git refs/heads/openhd-3.0)"
QOPENHD_SHA="$(fetch_head https://github.com/OpenHD/QOpenHD.git refs/heads/dev-release)"
SYSUTILS_SHA="$(fetch_head https://github.com/OpenHD/OpenHD-SysUtils.git refs/heads/main)"

if [[ -z "${OPENHD_SHA}" || -z "${QOPENHD_SHA}" || -z "${SYSUTILS_SHA}" ]]; then
  echo "Failed to resolve one or more upstream heads"
  exit 1
fi

sed -i "s/^SRCREV = \".*\"$/SRCREV = \"${OPENHD_SHA}\"/" \
  "${ROOT_DIR}/meta-orqa-builder/recipes-openhd/openhd/openhd_git.bbappend"
sed -i "s/^SRCREV = \".*\"$/SRCREV = \"${QOPENHD_SHA}\"/" \
  "${ROOT_DIR}/meta-orqa-builder/recipes-openhd/qopenhd/qopenhd_git.bbappend"
sed -i "s/^SRCREV = \".*\"$/SRCREV = \"${SYSUTILS_SHA}\"/" \
  "${ROOT_DIR}/meta-orqa-builder/recipes-openhd/openhd-sys-utils/openhd-sys-utils_git.bb"

printf 'openhd=%s\nqopenhd=%s\nopenhd_sysutils=%s\n' \
  "${OPENHD_SHA}" "${QOPENHD_SHA}" "${SYSUTILS_SHA}"

