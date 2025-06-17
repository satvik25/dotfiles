#!/usr/bin/env bash
set -euo pipefail

# Set console font

setfont ter-120n

echo "Font set."




# Use ls to list backlight device names
BACKLIGHT_DIR="/sys/class/backlight/$(ls /sys/class/backlight | head -n1)"

if [[ -z "$BACKLIGHT_DIR" || ! -e "$BACKLIGHT_DIR/max_brightness" ]]; then
    echo "❌ Failed to find usable backlight device."
    exit 1
fi

MAX_BRIGHTNESS=$(cat "$BACKLIGHT_DIR/max_brightness")

# Try setting brightness to max
if echo "$MAX_BRIGHTNESS" | tee "$BACKLIGHT_DIR/brightness" > /dev/null; then
    echo "✅ Brightness set to 100% using device: $(basename "$BACKLIGHT_DIR")"
else
    echo "❌ Failed to set brightness. Try running this script as root."
    exit 1
fi

echo "Brightness set to 100%."
