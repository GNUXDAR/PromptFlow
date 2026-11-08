#!/usr/bin/env bash
# Genera todos los iconos de PromptFlow a partir de assets/branding/*.svg.
# Requiere Inkscape. Vuelve a ejecutarlo si cambias el logo.
#
#   Android: mipmap-*/ic_launcher.png (legacy) + ic_launcher_foreground.png y
#            ic_launcher_monochrome.png (adaptativo / icono temático Android 13+)
#   Linux:   linux/packaging/icons/hicolor/<N>x<N>/apps/com.actecnology.promptflow.png
#   App:     assets/branding/logo.png (pantalla «Acerca de»)
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
B=assets/branding
APP_ID=com.actecnology.promptflow
png() { inkscape "$1" -w "$3" -h "$3" -o "$2" >/dev/null 2>&1; }

RES=android/app/src/main/res
declare -A LEGACY=([mdpi]=48 [hdpi]=72 [xhdpi]=96 [xxhdpi]=144 [xxxhdpi]=192)
declare -A ADAPTIVE=([mdpi]=108 [hdpi]=162 [xhdpi]=216 [xxhdpi]=324 [xxxhdpi]=432)
for d in "${!LEGACY[@]}"; do
  mkdir -p "$RES/mipmap-$d"
  png "$B/logo.svg"            "$RES/mipmap-$d/ic_launcher.png"            "${LEGACY[$d]}"
  png "$B/logo_foreground.svg" "$RES/mipmap-$d/ic_launcher_foreground.png" "${ADAPTIVE[$d]}"
  png "$B/logo_monochrome.svg" "$RES/mipmap-$d/ic_launcher_monochrome.png" "${ADAPTIVE[$d]}"
done

for n in 16 24 32 48 64 128 256 512; do
  dir="linux/packaging/icons/hicolor/${n}x${n}/apps"
  mkdir -p "$dir"
  png "$B/logo.svg" "$dir/$APP_ID.png" "$n"
done
mkdir -p linux/packaging/icons/hicolor/scalable/apps
cp "$B/logo.svg" "linux/packaging/icons/hicolor/scalable/apps/$APP_ID.svg"

png "$B/logo.svg" "$B/logo.png" 512
echo "Iconos generados."
