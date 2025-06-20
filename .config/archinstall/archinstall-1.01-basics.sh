#!/usr/bin/env bash
set -euo pipefail

# Set console font
echo -e "\033[35m[Font sizes]\033[0m"
echo -e "\033[35m[1]\033[0m 11.2 pt"
echo -e "\033[35m[2]\033[0m 12.0 pt"
echo -e "\033[35m[3]\033[0m 12.8 pt"
echo -e "\033[35m[4]\033[0m 13.6 pt"
read -r -p "Choose font size." answer_1 < /dev/tty

case "${answer_1:-2}" in
    1)
        setfont ter-112n
        echo "Font size S set."
        ;;
    2)
        setfont ter-120n
        echo "Font size M set."
        ;;
    3)
        setfont ter-128n
        echo "Font size L set."
        ;;
    4)
        setfont ter-136n
        echo "Font size XL set."
        ;;
    *)
        echo -e "\033[31m[Incorrect Input]\033[0m Choose 1, 2, 3 or 4."
        ;;
esac

# Set brightness
## List backlight device
BACKLIGHT_DIR="/sys/class/backlight/$(ls /sys/class/backlight | head -n1)"

## If no backlight device found
if [[ -z "$BACKLIGHT_DIR" || ! -e "$BACKLIGHT_DIR/max_brightness" ]]; then
    echo -e "\033[31m[FAILED]\033[0m to set brightness."
    exit 1
fi

## Find max brightness
MAX_BRIGHTNESS=$(cat "$BACKLIGHT_DIR/max_brightness")

##Set brightness
echo -e "\033[35m[Brightness %]\033[0m"
echo -e "\033[35m[1]\033[0m 0%"
echo -e "\033[35m[2]\033[0m 25%"
echo -e "\033[35m[3]\033[0m 50%"
echo -e "\033[35m[4]\033[0m 75%"
echo -e "\033[35m[5]\033[0m 100%"
read -r -p "Choose brightness level." answer_2 < /dev/tty
case "${answer_2:-5}" in
    1)
        VALUE=0
        ;;
    2)
        VALUE=$((MAX_BRIGHTNESS * 25 / 100))
        ;;
    3)
        VALUE=$((MAX_BRIGHTNESS * 50 / 100))
        ;;
    4)
        VALUE=$((MAX_BRIGHTNESS * 75 / 100))
        ;;
    5)
        VALUE=$MAX_BRIGHTNESS
        ;;
    *) 
        echo -e "\033[31m[Incorrect Input]\033[0m Choose 1, 2, 3, 4 or 5."
        ;;
esac

if echo "$VALUE" | tee "$BACKLIGHT_DIR/brightness" > /dev/null; then
    echo "Brightness set to $(( VALUE * 100 / MAX_BRIGHTNESS ))%."
else
    echo -e "\033[31m[FAILED]\033[0m to set brightness."
fi

echo -e "\033[32m[SUCCESS]\033[0m Basics configured."
