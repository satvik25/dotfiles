#!/usr/bin/env bash
set -euo pipefail

# Set console font

setfont ter-120n

echo "Font set."

# Find the backlight device
BACKLIGHT_DIR=$(find /sys/class/backlight/ -maxdepth 1 -type d | grep -v '/sys/class/backlight/$' | head -n1)

# If no device is found
if [[ -z "$BACKLIGHT_DIR" ]]; then
    echo "Failed to set brightness."
    exit 1
fi

# Get the max brightness
MAX_BRIGHTNESS=$(cat "$BACKLIGHT_DIR/max_brightness")

# Set brightness to max
echo "$MAX_BRIGHTNESS" | sudo tee "$BACKLIGHT_DIR/brightness" > /dev/null

echo "Brightness set to 100%."
