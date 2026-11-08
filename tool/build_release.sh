#!/usr/bin/env bash
# Compila PromptFlow para publicar y deja los artefactos con su nombre final:
#
#   dist/PromptFlow-<versión>-android-arm64.apk     (la mayoría de móviles)
#   dist/PromptFlow-<versión>-android-arm32.apk     (móviles antiguos)
#   dist/PromptFlow-<versión>-android-x86_64.apk    (emuladores, Chromebooks)
#   dist/PromptFlow-<versión>-android-universal.apk (todas las arquitecturas)
#   dist/PromptFlow-<versión>-android-play.aab      (para subir a Google Play)
#   dist/PromptFlow-<versión>-linux-<arch>.tar.gz   (descomprimir y ejecutar ./promptflow)
#   dist/promptflow_<versión>_<arch>.deb             (Debian/Ubuntu: sudo apt install ./…deb)
#   dist/SHA256SUMS
#
# Uso:  tool/build_release.sh [android|linux|deb|all]   (por defecto: all; linux incluye deb)
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
  # Google Play publica desde un Android App Bundle (firmado con la clave de subida).
  flutter build appbundle --release
  cp build/app/outputs/bundle/release/app-release.aab "$DIST/$NAME-android-play.aab"
fi

if [[ "$TARGET" == "linux" || "$TARGET" == "deb" || "$TARGET" == "all" ]]; then
  case "$(uname -m)" in x86_64) ARCH=x64 ;; aarch64|arm64) ARCH=arm64 ;; *) ARCH="$(uname -m)" ;; esac
  echo "→ Linux $VERSION ($ARCH)"
  [[ -f linux/third_party/vosk/libvosk.so ]] || echo "  ! sin libvosk: el paquete no tendrá voz (ejecuta tool/setup_vosk_linux.sh)"
  # build/flutter_assets se comparte entre debug y release: una compilación
  # debug previa (p. ej. tests de integración) deja kernel_blob.bin (~70 MB)
  # que la release no borra y acabaría dentro del paquete.
  rm -rf build/flutter_assets
  flutter build linux --release
  STAGE="$(mktemp -d)"
  trap 'rm -rf "$STAGE"' EXIT
  cp -r "build/linux/$ARCH/release/bundle" "$STAGE/$NAME"
  [[ "$TARGET" == "deb" ]] || tar -C "$STAGE" -czf "$DIST/$NAME-linux-$ARCH.tar.gz" "$NAME"

  # ── Paquete .deb ──────────────────────────────────────────────────────
  # /opt/promptflow (app), /usr/bin/promptflow, entrada de menú e iconos.
  if command -v dpkg-deb >/dev/null; then
    APP_ID=com.gnuxdar.promptflow
    DEB_ARCH="$(dpkg --print-architecture)"
    PKG="$STAGE/deb"
    mkdir -p "$PKG/DEBIAN" "$PKG/opt" "$PKG/usr/bin" "$PKG/usr/share/applications" "$PKG/usr/share/icons" \
             "$PKG/usr/share/doc/promptflow"
    cp -r "build/linux/$ARCH/release/bundle" "$PKG/opt/promptflow"
    rm -f "$PKG/opt/promptflow/install.sh" "$PKG/opt/promptflow/uninstall.sh" # el .deb usa apt
    ln -s /opt/promptflow/promptflow "$PKG/usr/bin/promptflow"
    cp -r linux/packaging/icons/hicolor "$PKG/usr/share/icons/"
    sed "s|@EXEC@|/usr/bin/promptflow|" "linux/packaging/$APP_ID.desktop" > "$PKG/usr/share/applications/$APP_ID.desktop"
    cp LICENSE "$PKG/usr/share/doc/promptflow/copyright"
    SIZE_KB="$(du -sk "$PKG/opt" "$PKG/usr" | awk '{s+=$1} END {print s}')"
    cat > "$PKG/DEBIAN/control" <<CONTROL
Package: promptflow
Version: $VERSION
Section: video
Priority: optional
Architecture: $DEB_ARCH
Installed-Size: $SIZE_KB
Maintainer: Arturo Cabrera (GNUXDAR) <6179849+GNUXDAR@users.noreply.github.com>
Homepage: https://github.com/GNUXDAR/PromptFlow
Depends: libc6, libstdc++6, libgtk-3-0t64 | libgtk-3-0, libglib2.0-0t64 | libglib2.0-0, libepoxy0
Recommends: libpulse0
Description: Teleprompter with remote control and offline voice following
 PromptFlow is a teleprompter for Linux and Android: smooth scrolling at the
 display refresh rate, horizontal/vertical mirroring, pauses and cues in the
 script, remote control from a phone over the local network, Bluetooth pedal
 support and offline voice following (Vosk) that highlights what you say.
CONTROL
    # Permisos estándar: directorios y ejecutables 755, el resto 644.
    find "$PKG" -type d -exec chmod 755 {} +
    find "$PKG/opt" "$PKG/usr" -type f -exec chmod 644 {} +
    chmod 755 "$PKG/opt/promptflow/promptflow"
    dpkg-deb --root-owner-group -Zxz --build "$PKG" "$DIST/promptflow_${VERSION}_${DEB_ARCH}.deb" >/dev/null
  else
    echo "  ! dpkg-deb no disponible: se omite el .deb"
  fi
fi

(cd "$DIST" && sha256sum PromptFlow-"$VERSION"-* promptflow_"$VERSION"_*.deb 2>/dev/null > SHA256SUMS)
echo
echo "Artefactos en dist/:"
ls -lh "$DIST" | awk 'NR>1 {print "  " $5 "\t" $9}'
