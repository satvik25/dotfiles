#!/usr/bin/env bash
# enable-user-units.sh
# Re-enables the user-level units you listed earlier.
# Run with:  ./enable-user-units.sh

set -euo pipefail

units=(
  hypridle.service
  hyprpolkitagent.service
  hyprsunset.service
  waybar.service
  wireplumber.service
  mpd.socket
  p11-kit-server.socket
  pipewire-pulse.socket
  pipewire.socket
)

for u in "${units[@]}"; do
  if systemctl --user list-unit-files | grep -q "^$u"; then
    echo "Enabling $u ..."
    systemctl --user enable --now "$u"
  else
    echo "Warning: $u not found; skipping." >&2
  fi
done

echo "All requested units processed."
