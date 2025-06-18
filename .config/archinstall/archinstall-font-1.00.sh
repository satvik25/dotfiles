#!/usr/bin/env bash
set -euo pipefail

# Get pixel dimensions and physical size (in mm) from xdpyinfo
if ! xdpyinfo &>/dev/null; then
    echo "xdpyinfo not available or not in a graphical session."
    exit 1
fi

read RES_X RES_Y <<< $(xdpyinfo | awk '/dimensions:/ {split($2,a,"x"); print a[1], a[2]}')
read MM_X MM_Y <<< $(xdpyinfo | awk '/dimensions:/ {gsub("[()]", "", $4); split($4,b,"x"); print b[1], b[2]}')

# Convert mm to inches
WIDTH_IN=$(echo "scale=2; $MM_X/25.4" | bc)
HEIGHT_IN=$(echo "scale=2; $MM_Y/25.4" | bc)

# Calculate average DPI
DPI_X=$(echo "scale=2; $RES_X/$WIDTH_IN" | bc)
DPI_Y=$(echo "scale=2; $RES_Y/$HEIGHT_IN" | bc)
AVG_DPI=$(echo "($DPI_X + $DPI_Y) / 2" | bc)

# Decide font based on avg DPI (thresholds chosen for typical comfort)
choose_font() {
    local dpi="$1"
    if   (( $(echo "$dpi < 100" | bc -l) )); then echo "ter-112n"
    elif (( $(echo "$dpi < 125" | bc -l) )); then echo "ter-116n"
    elif (( $(echo "$dpi < 145" | bc -l) )); then echo "ter-120n"
    elif (( $(echo "$dpi < 165" | bc -l) )); then echo "ter-124n"
    elif (( $(echo "$dpi < 185" | bc -l) )); then echo "ter-128n"
    elif (( $(echo "$dpi < 200" | bc -l) )); then echo "ter-132n"
    else echo "ter-136n"
    fi
}

FONT=$(choose_font "$AVG_DPI")
echo "Detected DPI: $AVG_DPI, selecting font: $FONT"

# Only try setfont if on a TTY (not in GUI or SSH)
if [[ $(tty) == /dev/tty* ]]; then
    setfont "$FONT" 2>/dev/null && echo "Set font: $FONT" || echo "Could not set font $FONT (not installed?)"
fi
