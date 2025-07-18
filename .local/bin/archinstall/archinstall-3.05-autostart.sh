#!/usr/bin/env bash
set -euo pipefail

# Set parameters
units=(
  bluetooth.service
  tlp.service
)

user_units=(
  hyprpolkitagent.service
  sddm.service
  hypridle.service
  waybar.service
  pipewire.socket
  wireplumber.service
  pipewire-pulse.socket
  swaync.service
  arch-update.timer
  rclone-bisync.timer
  sunsetr.service
  libinput-gestures.service
  hyprshell.service
  # p11-kit-server.socket
  # mpd.socket
)

# Enable units
for u in "${units[@]}"; do
  if systemctl list-unit-files | grep -q "^$u"; then
    echo "Enabling $u ..."
    sudo systemctl enable --now "$u"
  else
    echo "Warning: $u not found; skipping." >&2
  fi
done

for u in "${user_units[@]}"; do
  if systemctl --user list-unit-files | grep -q "^$u"; then
    echo "Enabling $u ..."
    systemctl --user enable --now "$u"
  else
    echo "Warning: $u not found; skipping." >&2
  fi
done

echo -e "\033[32m[SUCCESS]\033[0m Services enabled."
