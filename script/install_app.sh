#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="TopTodo"
SOURCE_APP="$ROOT_DIR/dist/$APP_NAME.app"
TARGET_DIR="/Applications"

"$ROOT_DIR/script/build_and_run.sh" --verify >/dev/null

if [[ ! -d "$TARGET_DIR" || ! -w "$TARGET_DIR" ]]; then
  TARGET_DIR="$HOME/Applications"
  mkdir -p "$TARGET_DIR"
fi

rm -rf "$TARGET_DIR/$APP_NAME.app"
cp -R "$SOURCE_APP" "$TARGET_DIR/$APP_NAME.app"

echo "Installed to: $TARGET_DIR/$APP_NAME.app"
