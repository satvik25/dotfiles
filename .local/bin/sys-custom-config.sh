#! /usr/bin/env bash
set -euo pipefail

# Copy system configuration files

cp -r ~/.local/share/sddm/themes/passage /usr/share/sddm/themes
cp -r ~/.config/environment /etc/environment
cp -r ~/.config/sddm.conf.d/sddm.conf /etc/sddm.conf.d/sddm.conf
cp -r ~/.local/share/icons/default/ /usr/share/icons
