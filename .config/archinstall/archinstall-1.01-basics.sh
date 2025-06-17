#!/usr/bin/env bash
set -euo pipefail

# Set console font

setfont ter-120n

echo "Font set."




# Check that backlight directory exists
if [[ ! -d /sys/class/backlight ]]; then
    echo "❌ /sys/class/backlight does not exist. Not a backlight-capable device?"
    exit 1
fi

# Find the first usable backlight device
BACKLIGHT_DIR=$(find /sys/class/backlight -mindepth 1 -maxdepth 1 -type d | head -n1)

# Debug output
echo "🕵️ Found backlight device directory: $BACKLIGHT_DIR"

if [[ -z "$BACKLIGHT_DIR" || ! -e "$BACKLIGHT_DIR/max_brightness" ]]; then
    echo "❌ Failed to find usable backlight device."
    exit 1
fi

# Get max brightness value
MAX_BRIGHTNESS=$(cat "$BACKLIGHT_DIR/max_brightness")

# Debug output
echo "ℹ️ Max brightness is: $MAX_BRIGHTNESS"

# Try setting brightness to max
if echo "$MAX_BRIGHTNESS" | tee "$BACKLIGHT_DIR/brightness" > /dev/null; then
    echo "✅ Brightness set to 100% using device: $(basename "$BACKLIGHT_DIR")"
else
    echo "❌ Failed to set brightness. Try running this script as root."
    exit 1
fi

echo "Brightness set to 100%."
