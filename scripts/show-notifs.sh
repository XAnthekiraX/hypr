#!/usr/bin/env bash

NOTIFS_FILE="$HOME/.local/state/caelestia/notifs.json"

if [[ ! -f "$NOTIFS_FILE" ]]; then
    notify-send "Error" "No se encontró el archivo de notificaciones" -u low
    exit 1
fi

notifs=$(jq -c '.[]' "$NOTIFS_FILE" 2>/dev/null)

if [[ -z "$notifs" ]]; then
    notify-send "Notificaciones" "No hay notificaciones" -u low -i dialog-information-symbolic
    exit 0
fi

hyprctl dispatch global caelestia:clearNotifs

sleep 0.3

count=0
while IFS= read -r notif; do
    summary=$(echo "$notif" | jq -r '.summary // empty')
    body=$(echo "$notif" | jq -r '.body // empty')
    appName=$(echo "$notif" | jq -r '.appName // empty')
    appIcon=$(echo "$notif" | jq -r '.appIcon // empty')
    image=$(echo "$notif" | jq -r '.image // empty')
    
    icon=""
    if [[ -n "$image" && -f "$image" ]]; then
        icon="$image"
    elif [[ -n "$appIcon" ]]; then
        icon="$appIcon"
    fi
    
    if [[ -n "$summary" ]]; then
        ((count++))
        if [[ -n "$icon" ]]; then
            notify-send "$summary" "$body" -i "$icon" -a "$appName" &
        else
            notify-send "$summary" "$body" -i dialog-information-symbolic -a "$appName" &
        fi
    fi
done <<< "$notifs"
