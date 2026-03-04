#!/usr/bin/env bash
# -------------------------------------------------------------------
# Script para aplicar un tema de Caelestia/Hyprland
# -------------------------------------------------------------------

export HOME=/home/anthekira

THEMES_DIR="$HOME/.config/hypr/scheme"
TARGET="$HOME/.local/state/caelestia/scheme.json"

valid_options=("morning" "afternoon" "night" "deepnight")

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <morning|afternoon|night|deepnight>"
    exit 1
fi

option="$1"

if [[ ! " ${valid_options[@]} " =~ " ${option} " ]]; then
    echo "Error: Invalid option '$option'"
    echo "Usage: $0 <morning|afternoon|night|deepnight>"
    exit 1
fi

THEME_PATH="$THEMES_DIR/${option}.json"

if [ ! -f "$THEME_PATH" ]; then
    echo "Error: archivo de tema no encontrado: $THEME_PATH"
    exit 1
fi

cp -f "$THEME_PATH" "$TARGET"
echo "Tema '${option}.json' aplicado correctamente → $TARGET"

if pgrep caelestia >/dev/null; then
    echo "Caelestia detectada, tema aplicado."
else
    echo "Caelestia no está corriendo, el tema se aplicará al iniciar."
fi

exit 0