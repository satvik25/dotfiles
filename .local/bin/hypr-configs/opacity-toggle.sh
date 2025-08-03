#!/usr/bin/env bash
set -euo pipefail

# 1) Where we store our toggle state (1=full, 0=reduced)
STATE_FILE="$HOME/.cache/hypr/hypr_opacity_state"
mkdir -p "${STATE_FILE%/*}"

# 2) Read last state, default to “1” if missing or malformed
last=$(cat "$STATE_FILE" 2>/dev/null || echo 1)
[[ "$last" =~ ^[01]$ ]] || last=1

# 3) Locate hyprctl
HYPRCTL=$(command -v hyprctl) || { echo "ERROR: hyprctl not in PATH" >&2; exit 1; }

# 4) (Optional) Log where we are and what we’re doing
LOG="$HOME/.cache/hypr/toggle_opacity.log"
mkdir -p "${LOG%/*}"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] last=$last" >>"$LOG"

# 5) Do the toggle via ‘dispatch’ (works when launched under Hyprland)
if [[ "$last" == "1" ]]; then
  echo "→ reducing opacity to 0.9/0.825" >>"$LOG"
  "$HYPRCTL" keyword decoration:active_opacity 0.9
  "$HYPRCTL" keyword decoration:inactive_opacity 0.8
  echo 0 >"$STATE_FILE"
else
  echo "→ restoring opacity to 1.0/1.0" >>"$LOG"
  "$HYPRCTL" keyword decoration:active_opacity 1
  "$HYPRCTL" keyword decoration:inactive_opacity 1
  echo 1 >"$STATE_FILE"
fi
