#!/usr/bin/env bash
set -euo pipefail

# Hyprland Plugins

hyprpm update
hyprpm add https://github.com/hyprwm/hyprland-plugins
hyprpm update
hyprpm list
hyprmpm enable hyprexpo
hyprpm reload
