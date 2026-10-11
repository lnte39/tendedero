#!/bin/bash
# Verify ordinary/preview identity and storage without launching the main app.
set -euo pipefail
cd "$(dirname "$0")/.."
WORK="$(mktemp -d -t textline-preview-checks)"
trap 'rm -rf "$WORK"' EXIT

swiftc -parse-as-library -swift-version 5 \
  Sources/Tendedero/AppIdentity.swift Sources/Tendedero/Inbox.swift \
  Sources/Tendedero/Localization.swift Tests/PreviewChecks.swift \
  -o "$WORK/checks"
"$WORK/checks"

APP="$WORK/Identity.app"
mkdir -p "$APP/Contents/MacOS"
cp "$WORK/checks" "$APP/Contents/MacOS/Identity"
cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleIdentifier</key><string>io.github.lnte39.TextlinePreviewValidation</string>
  <key>CFBundleExecutable</key><string>Identity</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>TextlinePreview</key><true/>
</dict></plist>
PLIST
"$APP/Contents/MacOS/Identity" --preview
