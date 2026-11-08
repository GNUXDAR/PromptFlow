#!/usr/bin/env bash
# Instala PromptFlow para el usuario actual (sin root):
#   ~/.local/share/promptflow/            la aplicación
#   ~/.local/share/applications/          entrada del menú
#   ~/.local/share/icons/hicolor/         icono
#   ~/.local/bin/promptflow               acceso desde la terminal
set -euo pipefail
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_ID=com.promptflow.promptflow
DATA="${XDG_DATA_HOME:-$HOME/.local/share}"
DEST="$DATA/promptflow"

if [[ "$SRC" != "$DEST" ]]; then
  rm -rf "$DEST"
  mkdir -p "$DEST"
  cp -r "$SRC"/. "$DEST"/
fi

mkdir -p "$DATA/icons/hicolor" "$DATA/applications" "$HOME/.local/bin"
cp -r "$DEST/data/icons/hicolor/." "$DATA/icons/hicolor/"
sed "s|@EXEC@|$DEST/promptflow|" "$DEST/data/$APP_ID.desktop" > "$DATA/applications/$APP_ID.desktop"
ln -sf "$DEST/promptflow" "$HOME/.local/bin/promptflow"

command -v update-desktop-database >/dev/null && update-desktop-database -q "$DATA/applications" || true
command -v gtk-update-icon-cache >/dev/null && gtk-update-icon-cache -q -t "$DATA/icons/hicolor" || true

echo "PromptFlow instalado. Búscalo en el menú de aplicaciones o ejecuta: promptflow"
