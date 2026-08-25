#!/bin/bash
# Builds PortWatch.app and packages it into a .dmg under dist/.
set -euo pipefail
cd "$(dirname "$0")/.."

APP_NAME="PortWatch"
DIST_DIR="dist"
APP_DIR="$DIST_DIR/$APP_NAME.app"

swift build -c release

rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS"
cp "$(swift build -c release --show-bin-path)/$APP_NAME" "$APP_DIR/Contents/MacOS/$APP_NAME"
cp "Resources/Info.plist" "$APP_DIR/Contents/Info.plist"

# Ad-hoc sign so Gatekeeper doesn't flat-out refuse to launch it.
codesign --force --deep --sign - "$APP_DIR"

DMG_PATH="$DIST_DIR/$APP_NAME.dmg"
rm -f "$DMG_PATH"
hdiutil create -volname "$APP_NAME" -srcfolder "$APP_DIR" -ov -format UDZO "$DMG_PATH"

echo "Built $DMG_PATH"
