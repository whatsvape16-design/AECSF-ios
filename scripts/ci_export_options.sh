#!/usr/bin/env bash
# Generate ExportOptions.plist from CI environment variables.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IOS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
OUTPUT="${IOS_DIR}/ExportOptions.ci.plist"

: "${APPLE_TEAM_ID:?APPLE_TEAM_ID is required}"
EXPORT_METHOD="${EXPORT_METHOD:-development}"

/usr/bin/plutil -create xml1 "$OUTPUT"
/usr/bin/plutil -insert method -string "$EXPORT_METHOD" "$OUTPUT"
/usr/bin/plutil -insert teamID -string "$APPLE_TEAM_ID" "$OUTPUT"
/usr/bin/plutil -insert signingStyle -string automatic "$OUTPUT"
/usr/bin/plutil -insert stripSwiftSymbols -bool true "$OUTPUT"
/usr/bin/plutil -insert uploadSymbols -bool true "$OUTPUT"

echo "[OK] Wrote $OUTPUT (method=$EXPORT_METHOD, team=$APPLE_TEAM_ID)"
