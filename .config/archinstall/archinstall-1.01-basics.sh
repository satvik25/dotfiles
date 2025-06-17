#!/usr/bin/env bash
set -euo pipefail

# Set console font
setfont ter-120n

echo "Font set."

# List backlight device
BACKLIGHT_DIR="/sys/class/backlight/$(ls /sys/class/backlight | head -n1)"

# If no backlight device found
if [[ -z "$BACKLIGHT_DIR" || ! -e "$BACKLIGHT_DIR/max_brightness" ]]; then
    echo "Failed to set brightness."
    exit 1
fi

# Find max brightness
MAX_BRIGHTNESS=$(cat "$BACKLIGHT_DIR/max_brightness")

# Set brightness to max
if echo "$MAX_BRIGHTNESS" | tee "$BACKLIGHT_DIR/brightness" > /dev/null; then
    echo "Brightness set to 100%."
else
    echo "Failed to set brightness."
    exit 1
fi

echo -e "\033[32m[SUCCESS]\033[0m Basics configured."
