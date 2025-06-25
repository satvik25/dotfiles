#!/usr/bin/env bash
# bt-profiles.sh — set BT card profiles

# Bluetooth
BT=$(pactl list cards short | awk '/bluez_card/ {print $2; exit}')
if [ -n "$BT" ]; then
  pactl set-card-profile "$BT" a2dp-sink
fi
