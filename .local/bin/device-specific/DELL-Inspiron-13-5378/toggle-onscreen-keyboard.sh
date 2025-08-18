#!/usr/bin/env bash

# ── CONFIG ──────────────────────────────────────────────
DEV_TABLET_STATE="/dev/input/by-path/pci-0000:00:1f.0-platform-INT33D6:00-event"
OSK_CMD="squeekboard"           # change to wvkbd, maliit‑keyboard, etc.
# ────────────────────────────────────────────────────────

# The pipeline stays running forever. stdbuf -oL forces
# each tool to flush on newline so single “0”/“1” tokens
# reach the loop immediately.
libinput debug-events --device "$DEV_TABLET_STATE" | \
  stdbuf -oL grep --line-buffered 'tablet-mode'     | \
  stdbuf -oL awk '{ print $NF }'                    | \
  while read -r mode; do
      if [[ "$mode" == "1" ]]; then            # tablet mode
          pgrep -x "$OSK_CMD"  >/dev/null 2>&1 || { "$OSK_CMD" & disown; }
      elif [[ "$mode" == "0" ]]; then          # laptop mode
          pkill -x "$OSK_CMD"  >/dev/null 2>&1 || true
      fi
  done
