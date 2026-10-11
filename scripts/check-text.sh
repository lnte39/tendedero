#!/bin/bash
# Synthetic regression checks; requires only the macOS Command Line Tools.
# Does not launch the app, read the general clipboard or require XCTest.
# Extra arguments are passed to swiftc.
set -euo pipefail
cd "$(dirname "$0")/.."

WORK="$(mktemp -d -t tendedero-text-checks)"
trap 'rm -rf "$WORK"' EXIT
SOURCES=()
for file in Sources/Tendedero/*.swift; do
  if [[ "$file" != "Sources/Tendedero/main.swift" ]]; then SOURCES+=("$file"); fi
done

swiftc -parse-as-library -module-name Tendedero -swift-version 5 \
  -target "$(uname -m)-apple-macosx14.0" \
  -module-cache-path "${TEXT_CHECK_MODULE_CACHE:-$WORK/ModuleCache}" \
  "$@" "${SOURCES[@]}" Tests/ClipboardChecks.swift -o "$WORK/text-checks"
"$WORK/text-checks"
