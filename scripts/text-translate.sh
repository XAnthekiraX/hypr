#!/usr/bin/env bash

set -e

IMAGE=$(mktemp /tmp/translate_XXXXX.png)

cleanup() {
    rm -f "$IMAGE"
}
trap cleanup EXIT

grim -l 0 -g "$(slurp)" "$IMAGE"

TEXT=$(tesseract -l spa+eng "$IMAGE" - 2>/dev/null)

if [ -z "$TEXT" ]; then
    notify-send "Traductor" "No se detectó texto en la imagen"
    exit 1
fi

TEXT_FORMATTED=$(echo "$TEXT" | tr '\n' ' ' | tr -s ' ')

TRANSLATED=$(echo -n "$TEXT_FORMATTED" | trans -b -t es) || TRANSLATED=""

if [ -z "$TRANSLATED" ]; then
    notify-send "Traductor" "Error al traducir, copiando texto original"
    TRANSLATED="$TEXT_FORMATTED"
fi

echo -n "$TRANSLATED" | wl-copy

notify-send "Texto traducido" "$TRANSLATED"
