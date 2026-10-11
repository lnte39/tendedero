#!/bin/bash
# Build a local, host-architecture preview without changing an installed app.
# Usage: bash scripts/build-preview.sh /absolute/output/directory
set -euo pipefail
export LC_ALL=C LANG=C
cd "$(dirname "$0")/.."
ROOT="$PWD"
DEST="${1:?Supply an absolute output directory}"
[[ "$DEST" = /* ]] || { echo 'Output directory must be absolute.' >&2; exit 1; }
APP="$DEST/Textline Preview.app"
[[ ! -e "$APP" && ! -L "$APP" ]] || { echo "Refusing to replace $APP" >&2; exit 1; }
BUILD="${PREVIEW_BUILD_DIR:-$ROOT/.build/preview}"
/usr/bin/swift build -c release --scratch-path "$BUILD"
BIN_DIR="$(/usr/bin/swift build -c release --scratch-path "$BUILD" --show-bin-path)"
mkdir -p "$DEST"
WORK="$(mktemp -d "$DEST/.textline-preview.XXXXXXXX")"
trap 'rm -rf "$WORK"' EXIT
STAGED="$WORK/Textline Preview.app"
mkdir -p "$STAGED/Contents/MacOS" "$STAGED/Contents/Resources"
cp "$BIN_DIR/Tendedero" "$STAGED/Contents/MacOS/TextlinePreview"

/usr/bin/swift scripts/make-preview-icon.swift "$WORK/icon.png"
ICONSET="$WORK/TextlinePreview.iconset"
mkdir -p "$ICONSET"
for size in 16 32 128 256 512; do
    /usr/bin/sips -z "$size" "$size" "$WORK/icon.png" --out "$ICONSET/icon_${size}x${size}.png" >/dev/null
    /usr/bin/sips -z "$((size*2))" "$((size*2))" "$WORK/icon.png" --out "$ICONSET/icon_${size}x${size}@2x.png" >/dev/null
done
/usr/bin/iconutil -c icns "$ICONSET" -o "$STAGED/Contents/Resources/TextlinePreview.icns"
LANGUAGES=""
for dir in Sources/Tendedero/Resources/*.lproj; do
    cp -R "$dir" "$STAGED/Contents/Resources/"
    LANGUAGES="$LANGUAGES<string>$(basename "$dir" .lproj)</string>"
done
cp LICENSE "$STAGED/Contents/Resources/LICENSE.txt"
printf '%s\n' 'Textline Preview is a modified local build of Tendedero.' \
    'Original source: https://github.com/alejandrobujan/tendedero' \
    'Fork: https://github.com/lnte39/tendedero' \
    'This preview has its own name and original icon; no upstream endorsement is implied.' \
    > "$STAGED/Contents/Resources/NOTICE.txt"
cat > "$STAGED/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleName</key><string>Textline Preview</string>
  <key>CFBundleDisplayName</key><string>Textline Preview</string>
  <key>CFBundleIdentifier</key><string>io.github.lnte39.TextlinePreview</string>
  <key>CFBundleExecutable</key><string>TextlinePreview</string>
  <key>CFBundleIconFile</key><string>TextlinePreview</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>0.1.0</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>CFBundleDevelopmentRegion</key><string>en</string>
  <key>CFBundleLocalizations</key><array>$LANGUAGES</array>
  <key>LSMinimumSystemVersion</key><string>14.0</string>
  <key>LSUIElement</key><true/>
  <key>NSHighResolutionCapable</key><true/>
  <key>TextlinePreview</key><true/>
  <key>NSDesktopFolderUsageDescription</key><string>Textline Preview watches this folder only if you enable screenshot handling or choose it explicitly.</string>
  <key>NSDocumentsFolderUsageDescription</key><string>Textline Preview watches folders you explicitly choose.</string>
  <key>NSDownloadsFolderUsageDescription</key><string>Textline Preview watches folders you explicitly choose.</string>
</dict></plist>
PLIST
/usr/bin/plutil -lint "$STAGED/Contents/Info.plist"
# Local ad-hoc signature only; no keychain lookup, identity use or notarization.
/usr/bin/codesign --force --sign - --timestamp=none "$STAGED"
/usr/bin/codesign --verify --deep --strict "$STAGED"
[[ ! -e "$APP" && ! -L "$APP" ]] || { echo "Output appeared during build; stopping." >&2; exit 1; }
mv -n "$STAGED" "$APP"
[[ ! -e "$STAGED" ]] || { echo 'Output already exists; no replacement made.' >&2; exit 1; }
printf 'Built (not launched): %s\n' "$APP"
