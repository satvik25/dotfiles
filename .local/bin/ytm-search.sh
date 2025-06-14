#!/usr/bin/env bash
##############################################################################
# ytm-search — Hyprland, no external deps except hyprctl & wtype
##############################################################################

query_raw="$*"

# 1. Encode query (space → +)
if command -v python3 >/dev/null; then
  query_enc=$(python3 - "$@" <<'PY'
import sys, urllib.parse
print(urllib.parse.quote_plus(" ".join(sys.argv[1:])))
PY
)
else
  query_enc=${query_raw// /+}
fi
search_url="https://music.youtube.com/search?q=${query_enc}"

# 2. Find existing YT Music window
win_addr=$(hyprctl clients | awk '
  BEGIN { addr="" }
  /Address:/     { addr=$2 }
  /class:\s*YTMusic|initialClass:\s*YTMusic|title:.*YouTube Music/i {
      print addr; exit
  }
')

if [[ -n "$win_addr" ]]; then
  hyprctl dispatch focuswindow "address:${win_addr}"
  if command -v wtype >/dev/null; then
    wtype -P ctrl+l
    wtype "${search_url}"
    wtype -P enter
    exit 0
  fi
fi

# 3. Otherwise launch new window
setsid google-chrome-stable \
  --user-data-dir="$HOME/.config/ytmusic-profile" \
  --profile-directory=Default \
  --app="${search_url}" \
  --class=YTMusic \
  --no-first-run --new-window \
  --enable-features=UseOzonePlatform \
  --ozone-platform=wayland \
  >/dev/null 2>&1 &
