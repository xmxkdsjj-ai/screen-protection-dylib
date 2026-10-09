#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${THEOS:-}" || ! -d "$THEOS" ]]; then
  echo "Set THEOS to an installed Theos directory with an iOS SDK." >&2
  exit 1
fi

make "$@"

dylib_path="$(find obj .theos/obj -type f -name 'ScreenProtection.dylib' -print -quit 2>/dev/null || true)"
if [[ -z "$dylib_path" ]]; then
  echo "Theos completed without producing ScreenProtection.dylib in the expected build directories." >&2
  exit 1
fi

mkdir -p dist
cp "$dylib_path" dist/ScreenProtection.dylib
echo "Built: $(pwd)/dist/ScreenProtection.dylib"
