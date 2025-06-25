#!/usr/bin/env bash
set -euo pipefail

# Set audio profiles

# Onboard
CARD=$(pactl list cards short | awk '/alsa_card/ {print $2; exit}')
if [ -n "$CARD" ]; then
  pactl set-card-profile "$CARD" pro-audio
fi

# Bluetooth
BT=$(pactl list cards short | awk '/bluez_card/ {print $2; exit}')
if [ -n "$BT" ]; then
  pactl set-card-profile "$BT" a2dp-sink
fi
