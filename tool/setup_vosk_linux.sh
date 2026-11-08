#!/usr/bin/env bash
# Descarga libvosk (Linux) y el modelo de voz en español para PromptFlow.
#
#   tool/setup_vosk_linux.sh            # x86_64 o aarch64 según la máquina
#
# * libvosk.so  → linux/third_party/vosk/  (CMake la copia a bundle/lib/)
# * modelo      → <Documentos>/PromptFlow/models/vosk-es  (donde la app lo busca)
#
# Ninguno de los dos se versiona en git (ver .gitignore).
set -euo pipefail

VOSK_VERSION="0.3.45"
MODEL_NAME="vosk-model-small-es-0.42"   # ~39 MB, admite gramática restringida

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIB_DIR="$ROOT/linux/third_party/vosk"
DOCS="$(xdg-user-dir DOCUMENTS 2>/dev/null || echo "$HOME/Documents")"
MODEL_DIR="$DOCS/PromptFlow/models/vosk-es"

case "$(uname -m)" in
  x86_64) ARCH="x86_64" ;;
  aarch64|arm64) ARCH="aarch64" ;;
  *) echo "Arquitectura no soportada: $(uname -m)" >&2; exit 1 ;;
esac

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

if [[ ! -f "$LIB_DIR/libvosk.so" ]]; then
  echo "→ Descargando libvosk $VOSK_VERSION ($ARCH)…"
  ZIP="vosk-linux-$ARCH-$VOSK_VERSION.zip"
  curl -fL --progress-bar -o "$TMP/$ZIP" \
    "https://github.com/alphacep/vosk-api/releases/download/v$VOSK_VERSION/$ZIP"
  mkdir -p "$TMP/lib" "$LIB_DIR"
  unzip -q "$TMP/$ZIP" -d "$TMP/lib"
  cp "$TMP"/lib/*/libvosk.so "$TMP"/lib/*/vosk_api.h "$LIB_DIR/"
else
  echo "✓ libvosk ya está en $LIB_DIR"
fi

if [[ ! -d "$MODEL_DIR" ]]; then
  echo "→ Descargando modelo $MODEL_NAME…"
  curl -fL --progress-bar -o "$TMP/model.zip" "https://alphacephei.com/vosk/models/$MODEL_NAME.zip"
  mkdir -p "$TMP/model" "$(dirname "$MODEL_DIR")"
  unzip -q "$TMP/model.zip" -d "$TMP/model"
  mv "$TMP/model/$MODEL_NAME" "$MODEL_DIR"
else
  echo "✓ Modelo ya está en $MODEL_DIR"
fi

echo
echo "Listo. Recompila para empaquetar libvosk.so:  flutter build linux  (o flutter run -d linux)"
