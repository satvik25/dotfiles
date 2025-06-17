#!/usr/bin/env bash
set -euo pipefail

# Set console font

setfont ter-120n

echo "Font set."

#!/usr/bin/env bash

# Find the first backlight device
BACKLIGHT_DIR=$(find /sys/class/backlight/ -mindepth 1 -maxdepth 1 -type d | head -n1)

# Check if we found any backlight device
if [[ -z "$BACKLIGHT_DIR" ]]; then
    echo "❌ Failed to find backlight device."
    exit 1
fi

# Get max brightness value
MAX_BRIGHTNESS=$(cat "$BACKLIGHT_DIR/max_brightness")

# Try setting brightness to max
if echo "$MAX_BRIGHTNESS" | tee "$BACKLIGHT_DIR/brightness" > /dev/null; then
    echo "✅ Brightness set to 100% using device: $(basename "$BACKLIGHT_DIR")"
else
    echo "❌ Failed to set brightness. Need root?"
    exit 1
fi

echo "Brightness set to 100%."
