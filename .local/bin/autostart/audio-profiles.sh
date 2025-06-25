#!/usr/bin/env bash

# Set audio card profiles on system start

# Onboard card → “pro-audio”
CARD=$(pactl list cards short | awk '/alsa_card/ {print $2; exit}')
if [ -n "$CARD" ]; then
  pactl set-card-profile "$CARD" pro-audio || \
    echo "Warning: pro-audio not available on $CARD"
fi

# Bluetooth AirPods → A2DP
BT=$(pactl list cards short | awk '/bluez_card/ {print $2; exit}')
if [ -n "$BT" ]; then
  pactl set-card-profile "$BT" a2dp-sink || \
    echo "Warning: a2dp_sink not available on $BT"
fi
