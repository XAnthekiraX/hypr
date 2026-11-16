#!/usr/bin/env bash

set -e

IMAGE=$(mktemp /tmp/ocr_XXXXX.png)

cleanup() {
    rm -f "$IMAGE"
}
trap cleanup EXIT

grim -l 0 -g "$(slurp)" "$IMAGE"

TEXT=$(tesseract -l spa+eng "$IMAGE" - 2>/dev/null)

if [ -z "$TEXT" ]; then
    notify-send "OCR" "No se detectó texto en la imagen"
    exit 1
fi

echo -n "$TEXT" | wl-copy

notify-send "Texto extraído" "$TEXT"
