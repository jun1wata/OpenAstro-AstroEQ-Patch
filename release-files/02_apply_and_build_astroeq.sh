#!/usr/bin/env bash
set -euo pipefail

PATCH="${1:-}"
BUILD_DIR="${BUILD_DIR:-AlpacaHTTP/build-astroeq-public}"

if [[ -z "$PATCH" ]]; then
  echo "Usage: $0 /path/to/openastro_astroeq_full.patch" >&2
  exit 2
fi

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"
PATCH="$(realpath "$PATCH")"

if [[ -n "$(git status --porcelain)" ]]; then
  echo "ERROR: target repository is not clean" >&2
  git status --short >&2
  exit 1
fi

git apply --check "$PATCH"
git apply --index "$PATCH"
git diff --cached --check

cmake -S AlpacaHTTP -B "$BUILD_DIR"
cmake --build "$BUILD_DIR" -j"$(nproc)"

echo "PASS: patch applied and build completed"
echo "No service restart, port 6800 change, or stock binary replacement was performed."
