#!/usr/bin/env bash
# Fire the helper after ≥1.5 s of continuous touch-jump errors or Δ≥8 px bursts
set -eo pipefail

THRESHOLD=8                 # |Δ|≥8 px = rogue
WINDOW_NS=1500000000        # 1.5 s in ns
HELPER="/home/7vik/.local/bin/device-specific/DELL-Inspiron-13-5378/touchpad/touchpad-rogue-helper.sh"

dev=$(libinput list-devices | awk '/Kernel:.*event/ {print $NF; exit}')
[[ -z $dev ]] && { echo "Touch-pad event node not found"; exit 1; }

start_ns=0

libinput debug-events --device "$dev" 2>&1 |
while IFS= read -r line; do
    now_ns=$(date +%s%N)
    rogue=0

    [[ $line == *"Touch jump detected"* ]] && rogue=1

    if [[ $rogue -eq 0 && $line =~ POINTER_SCROLL_FINGER|GESTURE_PINCH_UPDATE ]]; then
        if [[ $line == POINTER_SCROLL_FINGER* ]]; then
            vert=$(sed -n 's/.*vert \([-0-9.]*\)\/.*/\1/p'   <<<"$line")
            horiz=$(sed -n 's/.*horiz \([-0-9.]*\)\/.*/\1/p' <<<"$line")
        else
            read -ra f <<<"$line"   # … Δx Δy …
            horiz=${f[7]:-0}; vert=${f[8]:-0}
        fi
        av=${vert#-}; ah=${horiz#-}
        [[ ${av%%.*} -ge $THRESHOLD || ${ah%%.*} -ge $THRESHOLD ]] && rogue=1
    fi

    if (( rogue )); then
        (( start_ns == 0 )) && start_ns=$now_ns
        if (( now_ns - start_ns >= WINDOW_NS )); then
            "$HELPER"
            start_ns=0
            sleep 2           # grace period to let the pad re-enumerate
        fi
    else
        start_ns=0            # any clean packet closes the window
    fi
done
