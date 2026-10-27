#!/usr/bin/env bash
set -euo pipefail
ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

checks=(
  'AlpacaCore/src/vendors/skywatcher/skywatcher_telescope_driver.cpp:counts_per_revolution'
  'AlpacaCore/src/vendors/skywatcher/skywatcher_protocol_wrapper.cpp:Arduino'
  'AlpacaHTTP/web/index.html:value="astroeq"'
  'AlpacaHTTP/src/http/router.cpp:astroeq'
)

for item in "${checks[@]}"; do
  file="${item%%:*}"
  pat="${item#*:}"
  grep -q "$pat" "$file" || { echo "FAIL: $file missing $pat" >&2; exit 1; }
  echo "PASS: $file -> $pat"
done

git diff --check
echo "PASS: git diff --check"

for f in \
  AlpacaCore/tests/test_astroeq_gem.py \
  AlpacaCore/tests/test_astroeq_home.py \
  AlpacaCore/tests/test_skywatcher_serial_detection.py
do
  if [[ -f "$f" ]]; then
    if command -v pytest >/dev/null 2>&1; then
      pytest -q "$f"
    elif command -v python3 >/dev/null 2>&1; then
      python3 "$f"
    fi
  fi
done

if [[ -f AlpacaHTTP/tests/test_astroeq_ui.js ]] && command -v node >/dev/null 2>&1; then
  node AlpacaHTTP/tests/test_astroeq_ui.js
fi

echo "Verification completed."
