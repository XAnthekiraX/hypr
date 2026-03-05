#!/usr/bin/env bash

export HOME=/home/anthekira

SCHEME_DIR="$HOME/.config/hypr/scheme"
WALLPAPER_DIR="$HOME/Pictures/Wallpapers/wallpaperTime"
TARGET="$HOME/.local/state/caelestia/scheme.json"

get_period() {
    if [ -n "$TEST_HOUR" ]; then
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
        echo "Wallpaper directory not found: $wallpaper_path"
        return 1
    fi
    
    mapfile -t images < <(find "$wallpaper_path" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" \) 2>/dev/null)
    
    if [[ ${#images[@]} -eq 0 ]]; then
        echo "No images found in: $wallpaper_path"
        return 1
    fi
    
    local random_image
    random_image=$(shuf -n1 -e "${images[@]}")
    
    echo "Setting wallpaper: $(basename "$random_image")"
    caelestia wallpaper -f "$random_image"
}

set_theme() {
    local period="$1"
    local theme_path="$SCHEME_DIR/${period}.json"
    
    if [[ ! -f "$theme_path" ]]; then
        echo "Theme not found: $theme_path"
        return 1
    fi
    
    cp -f "$theme_path" "$TARGET"
    echo "Theme '${period}.json' applied"
}

period=$(get_period)

echo "========================================"
echo "Time: $(date +%H:%M) → Period: $period"
echo "========================================"

set_theme "$period"
set_wallpaper "$period"

if pgrep caelestia >/dev/null; then
    echo "Caelestia is running"
else
    echo "Caelestia not running, theme will apply on startup"
fi

echo "Done."
