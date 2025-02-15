#!/usr/bin/env sh

TOUCHPAD_FILE="/tmp/touchpad"
TOUCHPAD_LOCK="/tmp/touchpad.lock"

if [ ! -f "$TOUCHPAD_FILE" ]; then
    hyprctl -j devices | jq -r '.mice.[] | select(.name | contains("touchpad")) | .name' > "$TOUCHPAD_FILE"
fi

if [ ! -f "$TOUCHPAD_LOCK" ]; then
    echo "off" > "$TOUCHPAD_LOCK"
fi

TOUCHPAD=$(cat "$TOUCHPAD_LOCK")
TOUCHPAD_NAME=$(cat "$TOUCHPAD_FILE")

if [ "$TOUCHPAD" == "on" ]; then
    hyprctl keyword "device[$TOUCHPAD_NAME]:enabled" 'false'
    echo "off" > "$TOUCHPAD_LOCK"
    notify-send -t 2500 "Touchpad disabled"
else
    hyprctl keyword "device[$TOUCHPAD_NAME]:enabled" 'true'
    echo "on" > "$TOUCHPAD_LOCK"
    notify-send -t 2500 "Touchpad enabled"
fi
