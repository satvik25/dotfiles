#!/usr/bin/env bash

# Check if workspace 10 exists
while true; do
  if hyprctl -j workspaces | grep -q '"id":[[:space:]]*10'; then
  	# Rename workspace 10 if it exists
    hyprctl dispatch renameworkspace 10 ""
    break
  fi
  sleep 0.5
done
