#!/usr/bin/env bash

# Set audio card profiles on system start

# Onboard card → “pro-audio”
CARD=$(pactl list cards short | awk '/alsa_card/ {print $2; exit}')
if [ -n "$CARD" ]; then
  pactl set-card-profile "$CARD" pro-audio || \
    echo "Warning: pro-audio not available on $CARD"
fi
