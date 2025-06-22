#!/usr/bin/env bash
# --- start YT Music ------------------------------------------
google-chrome-stable \
  --user-data-dir="$HOME/.config/ytmusic-profile" \
  --profile-directory=Default \
  --app=https://music.youtube.com \
  --class=YTMusic --no-first-run --new-window \
  --enable-features=UseOzonePlatform --ozone-platform=wayland &
# --------------------------------------------------------------

# give Hyprland ~100 ms so the window lands
sleep 0.1

# rename the *current* workspace to the music icon
ws="$(hyprctl activeworkspace -j | jq -r '.id')"
hyprctl dispatch renameworkspace "$ws" " $ws  󰎇 "
