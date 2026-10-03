#!/bin/zsh
set -euo pipefail

project_dir=${0:A:h:h}
keystore_path="$project_dir/android/app/upload-keystore.jks"
key_alias=goodtv-release
keychain_service=ca.goodtools.goodtvlauncher.signing
keychain_account=goodtv-release
export JAVA_HOME="${JAVA_HOME:-/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home}"
export ANDROID_HOME="${ANDROID_HOME:-/opt/homebrew/share/android-commandlinetools}"

if [[ ! -f "$keystore_path" ]]; then
  signing_password="$(openssl rand -hex 24)"
  security add-generic-password -U \
    -s "$keychain_service" \
    -a "$keychain_account" \
    -w "$signing_password" >/dev/null
  "$JAVA_HOME/bin/keytool" -genkeypair -v \
    -keystore "$keystore_path" \
    -storepass "$signing_password" \
    -keypass "$signing_password" \
    -alias "$key_alias" \
    -keyalg RSA \
    -keysize 4096 \
    -validity 10000 \
    -dname "CN=Good Tools, O=Good Tools, C=CA" >/dev/null
else
  signing_password="$(security find-generic-password \
    -s "$keychain_service" \
    -a "$keychain_account" \
    -w)"
fi

export SIGNING_KEYSTORE_PASSWORD="$signing_password"
export SIGNING_KEY_PASSWORD="$signing_password"
export SIGNING_KEY_ALIAS="$key_alias"
flutter_bin="${FLUTTER_BIN:-/tmp/goodtv-build-tools/flutter/bin/flutter}"
cd "$project_dir"
"$flutter_bin" build apk \
  --release \
  --flavor github \
  --target-platform android-arm,android-arm64 \
  --dart-define=GOODTV_FIRE_TV=true
