#!/usr/bin/env bash
# --- start YT Music ------------------------------------------
google-chrome-stable --app=https://music.youtube.com
# --------------------------------------------------------------

# give Hyprland ~100 ms so the window lands
sleep 0.1

# rename the *current* workspace to the music icon
ws="$(hyprctl activeworkspace -j | jq -r '.id')"
hyprctl dispatch renameworkspace "$ws" " $ws  󰎇 "
