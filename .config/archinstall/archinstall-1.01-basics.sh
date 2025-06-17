#!/usr/bin/env bash
set -euo pipefail

# Set console font
# setfont ter-120n

# echo "Font set."




# Get resolution
read RES_X RES_Y <<< $(xdpyinfo | awk '/dimensions:/ {split($2, res, "x"); print res[1], res[2]}')

# Get screen size in mm
read MM_X MM_Y <<< $(xdpyinfo | awk '/dimensions:/ {gsub("[()]", "", $4); split($4, mm, "x"); print mm[1], mm[2]}')

# Convert mm to inches (1 inch = 25.4 mm)
WIDTH_IN=$(echo "scale=2; $MM_X / 25.4" | bc)
HEIGHT_IN=$(echo "scale=2; $MM_Y / 25.4" | bc)

# Calculate DPI
DPI_X=$(echo "scale=2; $RES_X / $WIDTH_IN" | bc)
DPI_Y=$(echo "scale=2; $RES_Y / $HEIGHT_IN" | bc)
AVG_DPI=$(echo "($DPI_X + $DPI_Y) / 2" | bc)

# Choose font based on average DPI
choose_font() {
    local dpi="$1"
    if (( $(echo "$dpi < 100" | bc -l) )); then
        echo "ter-112n"
    elif (( $(echo "$dpi < 125" | bc -l) )); then
        echo "ter-116n"
    elif (( $(echo "$dpi < 145" | bc -l) )); then
        echo "ter-120n"
    elif (( $(echo "$dpi < 165" | bc -l) )); then
        echo "ter-124n"
    elif (( $(echo "$dpi < 185" | bc -l) )); then
        echo "ter-128n"
    elif (( $(echo "$dpi < 200" | bc -l) )); then
        echo "ter-132n"
    else
        echo "ter-136n"
    fi
}

FONT=$(choose_font "$AVG_DPI")

echo "📏 Detected DPI: $AVG_DPI"
echo "🖋️  Suggested font: $FONT"

# Optional: Set the font if on TTY
if [[ -n "$TTY" || $(tty) == /dev/tty* ]]; then
    echo "⌨️  Setting font: $FONT"
    setfont "$FONT" 2>/dev/null || echo "⚠️  Font $FONT not found in consolefonts."
fi








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
