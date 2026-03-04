#!/usr/bin/env bash
# -------------------------------------------------------------------
# Script interactivo para aplicar un tema de Caelestia/Hyprland
# -------------------------------------------------------------------

# Carpeta donde están los JSON de los temas
THEMES_DIR="$HOME/.config/hypr/scheme"
# Archivo que se reemplaza para aplicar el tema
TARGET="$HOME/.local/state/caelestia/scheme.json"

# Lista de temas disponibles
THEMES=("morning.json" "afternoon.json" "night.json" "deepnight.json")

echo "Selecciona el tema que deseas aplicar:"
for i in "${!THEMES[@]}"; do
    echo "$((i+1))) ${THEMES[$i]}"
done

read -rp "Ingresa el número del tema: " CHOICE

# Validación básica
if ! [[ "$CHOICE" =~ ^[1-4]$ ]]; then
    echo "Selección inválida."
    exit 1
fi

SELECTED_THEME="${THEMES[$((CHOICE-1))]}"
THEME_PATH="$THEMES_DIR/$SELECTED_THEME"

# Verificar que exista
if [ ! -f "$THEME_PATH" ]; then
    echo "Error: archivo de tema no encontrado: $THEME_PATH"
    exit 1
fi

# Aplicar el tema sobrescribiendo scheme.json
cp -f "$THEME_PATH" "$TARGET"
echo "Tema '$SELECTED_THEME' aplicado correctamente → $TARGET"

# Recargar Caelestia (si está corriendo) para que tome el nuevo tema
if pgrep caelestia >/dev/null; then
    echo "Recargando Caelestia para aplicar el tema..."
    caelestia shell --reload
    echo "Recarga completada."
else
    echo "Caelestia no está corriendo, el tema se aplicará al iniciar."
fi

exit 0