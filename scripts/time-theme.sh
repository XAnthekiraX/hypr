#!/usr/bin/env bash

# Time-based theme + wallpaper switcher for Caelestia (Hyprland Lua config).
# Personal schemes live in ~/.config/caelestia/schemes.

set -euo pipefail

SCHEME_DIR="$HOME/.config/caelestia/schemes"
ICON_DIR="$HOME/.config/caelestia/Icons"
WALLPAPER_DIR="${XDG_PICTURES_DIR:-$HOME/Imágenes}/Wallpapers/wallpaperTime"
TARGET="$HOME/.local/state/caelestia/scheme.json"
REFERENCE="$SCHEME_DIR/_reference.json"

get_period() {
    if [ -n "${TEST_HOUR:-}" ]; then
        hour=$TEST_HOUR
        minute=0
    else
        hour=$(date +%-H)
        minute=$(date +%-M)
    fi

    total_minutes=$((hour * 60 + minute))

    if (( total_minutes >= 0 && total_minutes < 330 )); then
        echo "deepNight"
    elif (( total_minutes >= 330 && total_minutes < 510 )); then
        echo "sunrise"
    elif (( total_minutes >= 510 && total_minutes < 1065 )); then
        echo "day"
    elif (( total_minutes >= 1065 && total_minutes < 1140 )); then
        echo "sunset"
    else
        echo "night"
    fi
}

set_wallpaper() {
    local period="$1"
    local wallpaper_path="$WALLPAPER_DIR/$period"

    if [[ ! -d "$wallpaper_path" ]]; then
        echo "Wallpaper directory not found, skipping: $wallpaper_path"
        return 0
    fi

    mapfile -t images < <(find "$wallpaper_path" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" \) 2>/dev/null)

    if [[ ${#images[@]} -eq 0 ]]; then
        echo "No images found in: $wallpaper_path"
        return 0
    fi

    local random_image
    random_image=$(shuf -n1 -e "${images[@]}")

    echo "Setting wallpaper: $(basename "$random_image")"
    caelestia wallpaper -f "$random_image" || true
}

set_theme() {
    local period="$1"
    local theme_path="$SCHEME_DIR/${period}.json"

    if [[ ! -f "$theme_path" ]]; then
        echo "Theme not found: $theme_path"
        return 1
    fi

    mkdir -p "$(dirname "$TARGET")"

    # Normalise the old scheme files: fill in the keys added by newer
    # Caelestia releases and write the state scheme.json atomically.
    python3 - "$theme_path" "$TARGET" "$REFERENCE" <<'PY'
import json
import os
import sys
import tempfile

theme_path, target, reference = sys.argv[1:4]

with open(theme_path) as f:
    data = json.load(f)

colours = dict(data.get("colours", data))

# camelCase duplicates of the palette keys
aliases = {
    "primaryPaletteKeyColor": "primary_paletteKeyColor",
    "secondaryPaletteKeyColor": "secondary_paletteKeyColor",
    "tertiaryPaletteKeyColor": "tertiary_paletteKeyColor",
    "neutralPaletteKeyColor": "neutral_paletteKeyColor",
    "neutralVariantPaletteKeyColor": "neutral_variant_paletteKeyColor",
}
for new, old in aliases.items():
    if new not in colours and old in colours:
        colours[new] = colours[old]

# Dim variants are new; derive them from their base colour
for dim, base in {
    "primaryDim": "primary",
    "secondaryDim": "secondary",
    "tertiaryDim": "tertiary",
    "errorDim": "error",
}.items():
    if dim not in colours and base in colours:
        colours[dim] = colours[base]

# Anything still missing comes from the reference scheme
if os.path.exists(reference):
    with open(reference) as f:
        ref = json.load(f)
    for key, value in ref.get("colours", {}).items():
        colours.setdefault(key, value)

data["colours"] = colours
data.setdefault("name", os.path.splitext(os.path.basename(theme_path))[0])
data.setdefault("flavour", "default")
data.setdefault("mode", "dark")
data.setdefault("variant", "tonalspot")

fd, tmp = tempfile.mkstemp(dir=os.path.dirname(target))
with os.fdopen(fd, "w") as f:
    json.dump(data, f, ensure_ascii=False)
os.replace(tmp, target)
PY

    # Regenerate every themed output: Hyprland current.lua, GTK, Qt,
    # fuzzel, btop, terminal colours, etc.
    python3 - "$TARGET" <<'PY'
import json
import sys

from caelestia.utils.theme import apply_colours

with open(sys.argv[1]) as f:
    data = json.load(f)

apply_colours(data["colours"], data.get("mode", "dark"))
PY

    echo "Theme '${period}.json' applied"
}

period=$(get_period)

echo "========================================"
echo "Time: $(date +%H:%M) -> Period: $period"
echo "========================================"

set_theme "$period" || echo "Theme could not be applied"
set_wallpaper "$period"

if pgrep caelestia >/dev/null 2>&1; then
    echo "Caelestia is running"
else
    echo "Caelestia not running, theme will apply on startup"
fi

case "$period" in
    deepNight) icon="$ICON_DIR/DeepNight.svg" ;;
    sunrise)   icon="$ICON_DIR/Sunrise.svg" ;;
    day)       icon="$ICON_DIR/Day.svg" ;;
    sunset)    icon="$ICON_DIR/Sunset.svg" ;;
    night)     icon="$ICON_DIR/Night.svg" ;;
    *)         icon="" ;;
esac

if [[ -n "$icon" && -f "$icon" ]]; then
    notify-send -i "$icon" "Tema aplicado" "$period"
else
    notify-send "Tema aplicado" "$period"
fi
