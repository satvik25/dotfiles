#!/usr/bin/env bash
# move_ws.sh <target-workspace-id>
# Move all windows from the *active* workspace to <target-workspace-id>

set -euo pipefail

# ---- sanity checks ---------------------------------------------------------
if [[ $# -ne 1 ]]; then
  echo "Usage: $(basename "$0") <target-workspace>" >&2
  exit 1
fi
DST="$1"

# ---- determine the active (source) workspace -------------------------------
# Focused monitor has "focused: true"; its activeWorkspace carries the ID
SRC=$(hyprctl monitors -j \
      | jq -r '.[] | select(.focused==true).activeWorkspace.id')  # :contentReference[oaicite:0]{index=0}

if [[ -z "$SRC" || "$SRC" == "null" ]]; then
  echo "Cannot detect active workspace!" >&2
  exit 1
fi
[[ "$SRC" -eq "$DST" ]] && { echo "Source and target are the same ($SRC). Nothing to do."; exit 0; }

# ---- move every client -----------------------------------------------------
hyprctl clients -j \
 | jq -r ".[] | select(.workspace.id==$SRC) | .address" \
 | while read -r addr; do
       hyprctl dispatch movetoworkspacesilent "${DST},address:${addr}"  # :contentReference[oaicite:1]{index=1}
   done
