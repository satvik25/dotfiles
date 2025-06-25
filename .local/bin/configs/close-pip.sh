#!/usr/bin/env bash
# Close Picture-in-Picture (PiP) with Esc

if hyprctl activewindow -j | \
   grep -qi '"title":[[:space:]]*"[^"]*picture[- ]in[- ]picture"'
then
    hyprctl dispatch killactive
fi
