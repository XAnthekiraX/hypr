#!/usr/bin/env bash
# -------------------------------------------------------------------
# Script automático para aplicar tema y wallpaper según la hora
# Schedule:
#   06:00 - 11:59 → morning
#   12:00 - 17:59 → afternoon
#   18:00 - 23:59 → night
#   00:00 - 05:59 → deepnight
# -------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

get_period() {
    if [ -n "$TEST_HOUR" ]; then
        hour=$TEST_HOUR
    else
        hour=$(date +%-H)
    fi
    
    if (( hour >= 6 && hour < 12 )); then
        echo "morning"
    elif (( hour >= 12 && hour < 18 )); then
        echo "afternoon"
    elif (( hour >= 18 && hour < 24 )); then
        echo "night"
    else
        echo "deepnight"
    fi
}

period=$(get_period)

echo "Hora actual: $(date +%H:%M) → Aplicando: $period"

"$SCRIPT_DIR/theme-switch.sh" "$period"

echo "Cambiando wallpaper..."
"$SCRIPT_DIR/wallpaper-select.sh" "$period" 2>&1 | head -1

echo "Completado."
