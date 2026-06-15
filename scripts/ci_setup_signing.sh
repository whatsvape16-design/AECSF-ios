#!/usr/bin/env bash
# Import iOS signing certificate + provisioning profile (GitHub Actions / generic CI).
set -euo pipefail

: "${BUILD_CERTIFICATE_BASE64:?BUILD_CERTIFICATE_BASE64 is required}"
: "${P12_PASSWORD:?P12_PASSWORD is required}"
: "${BUILD_PROVISION_PROFILE_BASE64:?BUILD_PROVISION_PROFILE_BASE64 is required}"
: "${KEYCHAIN_PASSWORD:?KEYCHAIN_PASSWORD is required}"

KEYCHAIN_PATH="${RUNNER_TEMP:-/tmp}/app-signing.keychain-db"
CERT_PATH="${RUNNER_TEMP:-/tmp}/build_certificate.p12"
PROFILE_PATH="${HOME}/Library/MobileDevice/Provisioning Profiles"
PROFILE_FILE="${PROFILE_PATH}/diya_vape.mobileprovision"

security create-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
security set-keychain-settings -lut 21600 "$KEYCHAIN_PATH"
security unlock-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"

echo "$BUILD_CERTIFICATE_BASE64" | base64 --decode > "$CERT_PATH"
security import "$CERT_PATH" -P "$P12_PASSWORD" -A -t cert -f pkcs12 -k "$KEYCHAIN_PATH"
security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
security list-keychain -d user -s "$KEYCHAIN_PATH"

mkdir -p "$PROFILE_PATH"
echo "$BUILD_PROVISION_PROFILE_BASE64" | base64 --decode > "$PROFILE_FILE"

echo "[OK] Keychain and provisioning profile installed"
