#!/usr/bin/env bash
#
# chrome-incog.sh — launch Chrome incognito & force full opacity

# 1) Launch Browser in incognito on the background
# google-chrome-stable --incognito "$@" &
firefox --private-window "$@" &
# 2) Give it a moment to map and focus
sleep 1.5

# 3) Grab the active window’s address via JSON
winid=$(hyprctl activewindow -j | jq -r .address)
if [[ -z "$winid" ]]; then
  echo "Error: no active window found" >&2
  exit 1
fi

# 4) Dispatch the setprop opacity command on that window
hyprctl dispatch setprop address:$(hyprctl activewindow -j | jq -r .address) opaque on
