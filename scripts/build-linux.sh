#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"
LOVE_FILE="$DIST_DIR/breaker.love"
BIN_FILE="$DIST_DIR/breaker-linux-x86_64"

mkdir -p "$DIST_DIR"
rm -f "$LOVE_FILE" "$BIN_FILE"

(cd "$ROOT_DIR" && zip -9 -r "$LOVE_FILE" conf.lua main.lua src)

cat "$(command -v love)" "$LOVE_FILE" > "$BIN_FILE"
chmod +x "$BIN_FILE"

echo "Built: $BIN_FILE"
