#!/usr/bin/env bash
set -euo pipefail

# Vercel build step for Flutter Web.
# Downloads Flutter SDK at build time, builds the web bundle into build/web.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
APP_DIR="$ROOT_DIR/price_bet"

FLUTTER_VERSION="${FLUTTER_VERSION:-3.41.4}"
FLUTTER_SDK_DIR="$ROOT_DIR/.flutter-sdk"

echo "Using Flutter $FLUTTER_VERSION" >&2

if [ ! -d "$FLUTTER_SDK_DIR/flutter" ]; then
  echo "Downloading Flutter SDK..." >&2
  mkdir -p "$FLUTTER_SDK_DIR"
  curl -sSL "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
    | tar -xJ -C "$FLUTTER_SDK_DIR"
fi

export PATH="$FLUTTER_SDK_DIR/flutter/bin:$PATH"

cd "$APP_DIR"
flutter --version
flutter config --enable-web
flutter pub get
flutter build web --release

