#!/usr/bin/env bash
# Toggle OSDLyrics on/off

if pgrep -x osdlyrics >/dev/null; then
  pkill -x osdlyrics
else
  osdlyrics &
fi
