#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BOARD="${1:-}"
OUT_DIR="${2:-${ROOT_DIR}/sdk-bundles/${BOARD}}"
PART_SIZE="${PART_SIZE:-95m}"
BUILD_ROOT="${ROOT_DIR}/build/${BOARD}/build/tmp/deploy/sdk"
EXTRACT_ROOT="${ROOT_DIR}/sdk-extracted/${BOARD}"

if [[ -z "${BOARD}" ]]; then
  echo "Usage: $0 <apb|avp|evk|standalone> [out_dir]"
  exit 1
fi

mkdir -p "${OUT_DIR}"
rm -rf "${EXTRACT_ROOT}"
mkdir -p "${EXTRACT_ROOT}"

SDK_INSTALLER="$(find "${BUILD_ROOT}" -maxdepth 1 -type f -name '*.sh' | sort | head -n 1)"
if [[ -z "${SDK_INSTALLER}" ]]; then
  echo "No SDK installer found in ${BUILD_ROOT}"
  exit 1
fi

chmod +x "${SDK_INSTALLER}"
"${SDK_INSTALLER}" -y -d "${EXTRACT_ROOT}"

SDK_ENV_FILE="$(find "${EXTRACT_ROOT}" -maxdepth 2 -type f -name 'environment-setup-*' | sort | head -n 1)"
if [[ -z "${SDK_ENV_FILE}" ]]; then
  echo "No environment-setup file found after extracting SDK"
  exit 1
fi

rm -f "${OUT_DIR}/sdk-bundle.tar.zst.part-"*
tar --zstd -cf - -C "${EXTRACT_ROOT}" . | split -b "${PART_SIZE}" -d -a 3 - "${OUT_DIR}/sdk-bundle.tar.zst.part-"

cat > "${OUT_DIR}/sdk-manifest.txt" <<EOF
board=${BOARD}
generated_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)
sdk_installer=$(basename "${SDK_INSTALLER}")
environment_setup=$(realpath --relative-to="${EXTRACT_ROOT}" "${SDK_ENV_FILE}")
part_size=${PART_SIZE}
EOF

find "${OUT_DIR}" -maxdepth 1 -type f | sort

