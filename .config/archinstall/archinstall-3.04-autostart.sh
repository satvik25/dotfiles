#!/usr/bin/env bash
set -euo pipefail

# Enable user units

units=(
  hyprpolkitagent.service
  hypridle.service
  hyprsunset.service
  waybar.service
  pipewire.socket
  p11-kit-server.socket
  wireplumber.service
  pipewire-pulse.socket
  # mpd.socket
)

for u in "${units[@]}"; do
  if systemctl --user list-unit-files | grep -q "^$u"; then
    echo "Enabling $u ..."
    systemctl --user enable --now "$u"
  else
    echo "Warning: $u not found; skipping." >&2
  fi
done

echo -e "\033[32m[SUCCESS]\033[0m Services enabled."
