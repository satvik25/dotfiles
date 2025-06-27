#!/usr/bin/env bash
#
# volume-step.sh — snap to nearest 5% then set absolute linear volume with wpctl
# Usage: volume-step.sh +5   or   volume-step.sh -5

step=$1   # e.g. "+5" or "-5"

# 1. Read current percentage (first value) from pactl
current=$(pactl get-sink-volume @DEFAULT_SINK@ \
  | awk '/Volume:/ {print $5; exit}' \
  | tr -d '%')

# Bail if we didn’t get a number
if [[ -z "$current" ]]; then
  echo "Error: couldn’t parse current volume from pactl" >&2
  exit 1
fi

# 2. Snap to nearest multiple of 5
nearest=$(( (current + 2) / 5 * 5 ))

# 3. Compute the target = snapped + step
target=$(( nearest + step ))

# 4. Clamp into the 0–100 range
(( target > 100 )) && target=100
(( target <   0 ))   && target=0

# 5. Apply as an *absolute* linear‐volume percent with wpctl
wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ "${target}%"

# (Optional) Uncomment for debug popups:
# notify-send "Volume" "cur=${current} → snapped=${nearest} → set=${target}"
