#!/usr/bin/env bash
# Compila PromptFlow para publicar y deja los artefactos con su nombre final:
#
#   dist/PromptFlow-<versión>-android-arm64.apk     (la mayoría de móviles)
#   dist/PromptFlow-<versión>-android-arm32.apk     (móviles antiguos)
#   dist/PromptFlow-<versión>-android-x86_64.apk    (emuladores, Chromebooks)
#   dist/PromptFlow-<versión>-android-universal.apk (todas las arquitecturas)
#   dist/PromptFlow-<versión>-linux-<arch>.tar.gz   (descomprimir y ejecutar ./promptflow)
#   dist/SHA256SUMS
#
# Uso:  tool/build_release.sh [android|linux|all]   (por defecto: all)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
TARGET="${1:-all}"
VERSION="$(sed -n 's/^version:[[:space:]]*\([0-9.]*\).*/\1/p' pubspec.yaml)"
NAME="PromptFlow-$VERSION"
DIST="$ROOT/dist"
mkdir -p "$DIST"

if [[ "$TARGET" == "android" || "$TARGET" == "all" ]]; then
  echo "→ Android $VERSION"
  OUT=build/app/outputs/flutter-apk
  flutter build apk --release --split-per-abi
  cp "$OUT/app-arm64-v8a-release.apk"   "$DIST/$NAME-android-arm64.apk"
  cp "$OUT/app-armeabi-v7a-release.apk" "$DIST/$NAME-android-arm32.apk"
  cp "$OUT/app-x86_64-release.apk"      "$DIST/$NAME-android-x86_64.apk"
  flutter build apk --release
  cp "$OUT/app-release.apk"             "$DIST/$NAME-android-universal.apk"
fi

if [[ "$TARGET" == "linux" || "$TARGET" == "all" ]]; then
  case "$(uname -m)" in x86_64) ARCH=x64 ;; aarch64|arm64) ARCH=arm64 ;; *) ARCH="$(uname -m)" ;; esac
  echo "→ Linux $VERSION ($ARCH)"
  [[ -f linux/third_party/vosk/libvosk.so ]] || echo "  ! sin libvosk: el paquete no tendrá voz (ejecuta tool/setup_vosk_linux.sh)"
  flutter build linux --release
  STAGE="$(mktemp -d)"
  trap 'rm -rf "$STAGE"' EXIT
  cp -r "build/linux/$ARCH/release/bundle" "$STAGE/$NAME"
  tar -C "$STAGE" -czf "$DIST/$NAME-linux-$ARCH.tar.gz" "$NAME"
fi

(cd "$DIST" && sha256sum PromptFlow-"$VERSION"-* > SHA256SUMS)
echo
echo "Artefactos en dist/:"
ls -lh "$DIST" | awk 'NR>1 {print "  " $5 "\t" $9}'
