#!/usr/bin/env bash

# Autostart special apps in special workspaces

## Switch to last workspace
hyprctl dispatch workspace 10
 
## Launch apps
gtk-launch whatsapp
thunderbird > /dev/null 2>&1 &
gtk-launch ytm

## Break to ensure everything is up and running
sleep 10

# Move to special workspace
hyprctl dispatch movetoworkspacesilent special:whatsapp,address:0x$(hyprctl clients | grep -E '^Window .*web.whatsapp.com:$' | awk '{print $2}')
hyprctl dispatch movetoworkspacesilent special:mail,address:0x$(hyprctl clients | grep -E '^Window .*Mozilla Thunderbird:$' | awk '{print $2}')
hyprctl dispatch movetoworkspacesilent special:music,address:0x$(hyprctl clients | grep -E '^Window .*YouTube Music:$' | awk '{print $2}')

# Return to first workspace
hyprctl dispatch workspace 1
