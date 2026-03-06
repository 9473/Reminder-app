#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="Reminder"
APP_PATH="/Applications/$APP_NAME.app"

"$ROOT_DIR/Scripts/package_app.sh"

if [[ -d "$APP_PATH" ]]; then
  rm -rf "$APP_PATH"
fi

ditto "$ROOT_DIR/dist/$APP_NAME.app" "$APP_PATH"

echo "Installed to:"
echo "$APP_PATH"

open "$APP_PATH"
