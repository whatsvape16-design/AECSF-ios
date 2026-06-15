#!/usr/bin/env bash
# Build Diya Vape iOS app. Requires macOS + Xcode 15+.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT="$ROOT_DIR/DiyaVape.xcodeproj"
SCHEME="DiyaVape"
OUTPUT_DIR="$ROOT_DIR/output"
ARCHIVE_PATH="$OUTPUT_DIR/DiyaVape.xcarchive"
EXPORT_DIR="$OUTPUT_DIR/ipa"
EXPORT_PLIST="$ROOT_DIR/ExportOptions.plist"

MODE="${1:-simulator}"

echo "==> Preparing iOS icons"
python3 "$ROOT_DIR/scripts/prepare_ios_icons.py"

mkdir -p "$OUTPUT_DIR"

case "$MODE" in
  simulator)
    echo "==> Building for iOS Simulator (Debug)"
    xcodebuild \
      -project "$PROJECT" \
      -scheme "$SCHEME" \
      -configuration Debug \
      -destination "generic/platform=iOS Simulator" \
      -derivedDataPath "$OUTPUT_DIR/DerivedData" \
      build
    APP_PATH="$OUTPUT_DIR/DerivedData/Build/Products/Debug-iphonesimulator/DiyaVape.app"
    if [[ -d "$APP_PATH" ]]; then
      echo "[OK] Simulator app: $APP_PATH"
    fi
    ;;
  archive)
    echo "==> Archiving for device (Release)"
    xcodebuild \
      -project "$PROJECT" \
      -scheme "$SCHEME" \
      -configuration Release \
      -destination "generic/platform=iOS" \
      -archivePath "$ARCHIVE_PATH" \
      archive
    echo "[OK] Archive: $ARCHIVE_PATH"
    if [[ -f "$EXPORT_PLIST" ]]; then
      echo "==> Exporting IPA"
      rm -rf "$EXPORT_DIR"
      xcodebuild -exportArchive \
        -archivePath "$ARCHIVE_PATH" \
        -exportPath "$EXPORT_DIR" \
        -exportOptionsPlist "$EXPORT_PLIST"
      echo "[OK] IPA export dir: $EXPORT_DIR"
    else
      echo "[WARN] Missing $EXPORT_PLIST — archive only, no IPA export"
      echo "       Create ExportOptions.plist with your Team ID and method (development/ad-hoc/app-store)."
    fi
    ;;
  *)
    echo "Usage: $0 [simulator|archive]"
    exit 1
    ;;
esac
