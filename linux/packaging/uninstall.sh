#!/usr/bin/env bash
# Desinstala PromptFlow del usuario actual. Tus guiones (Documentos/PromptFlow) no se tocan.
set -euo pipefail
APP_ID=com.actecnology.promptflow
DATA="${XDG_DATA_HOME:-$HOME/.local/share}"
rm -rf "$DATA/promptflow"
rm -f "$DATA/applications/$APP_ID.desktop" "$HOME/.local/bin/promptflow"
find "$DATA/icons/hicolor" -name "$APP_ID.*" -delete 2>/dev/null || true
command -v update-desktop-database >/dev/null && update-desktop-database -q "$DATA/applications" || true
command -v gtk-update-icon-cache >/dev/null && gtk-update-icon-cache -q -t "$DATA/icons/hicolor" || true
echo "PromptFlow desinstalado. Tus guiones siguen en la carpeta Documentos/PromptFlow."
