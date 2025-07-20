#!/usr/bin/env bash
set -euo pipefail

# Hyprland Plugins

hyprpm update
hyprpm add https://github.com/hyprwm/hyprland-plugins
hyprpm add https://github.com/horriblename/hyprgrass
hyprpm update
hyprpm list
hyprmpm enable hyprexpo
hyprpm enable hyprgrass
hyprpm reload
