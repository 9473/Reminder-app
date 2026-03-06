#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"
APP_NAME="Reminder"
ARCHIVE_PATH="$DIST_DIR/$APP_NAME-macOS.zip"

rm -f "$ARCHIVE_PATH"
ditto -c -k --sequesterRsrc --keepParent "$DIST_DIR/$APP_NAME.app" "$ARCHIVE_PATH"

echo "Created archive:"
echo "$ARCHIVE_PATH"
