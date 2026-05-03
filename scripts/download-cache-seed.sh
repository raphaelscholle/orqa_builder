#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BOARD="${1:-}"
REPO="${GITHUB_REPOSITORY:-raphaelscholle/orqa_builder}"
TAG="${CACHE_SEED_TAG_PREFIX:-cache-seed}-${BOARD}"
DEST_DIR="${ROOT_DIR}/cache-seed-download/${BOARD}"

if [[ -z "${BOARD}" ]]; then
  echo "Usage: $0 <apb|avp|evk|standalone>"
  exit 1
fi

if [[ -z "${GITHUB_TOKEN:-}" ]]; then
  echo "GITHUB_TOKEN not set, skipping cache seed download"
  exit 0
fi

mkdir -p "${DEST_DIR}"

python3 - "$REPO" "$TAG" "$DEST_DIR" <<'PY'
import json
import os
import sys
import urllib.error
import urllib.request

repo, tag, dest_dir = sys.argv[1:4]
token = os.environ["GITHUB_TOKEN"]

headers = {
    "Authorization": f"Bearer {token}",
    "Accept": "application/vnd.github+json",
    "User-Agent": "orqa-builder-cache-seed",
    "X-GitHub-Api-Version": "2022-11-28",
}

url = f"https://api.github.com/repos/{repo}/releases/tags/{tag}"
req = urllib.request.Request(url, headers=headers)
try:
    with urllib.request.urlopen(req, timeout=30) as resp:
        release = json.load(resp)
except urllib.error.HTTPError as e:
    if e.code == 404:
        print(f"No release found for tag {tag}, skipping")
        sys.exit(0)
    raise

for asset in release.get("assets", []):
    name = asset["name"]
    if not (name.startswith("downloads.tar.zst.part-") or name.startswith("sstate-cache.tar.zst.part-") or name == "manifest.txt"):
        continue
    out_path = os.path.join(dest_dir, name)
    req = urllib.request.Request(asset["url"], headers={**headers, "Accept": "application/octet-stream"})
    with urllib.request.urlopen(req, timeout=120) as resp, open(out_path, "wb") as f:
        f.write(resp.read())
    print(out_path)
PY

if compgen -G "${DEST_DIR}/*" > /dev/null; then
  "${ROOT_DIR}/scripts/restore-cache-seed.sh" "${BOARD}" "${DEST_DIR}"
fi

