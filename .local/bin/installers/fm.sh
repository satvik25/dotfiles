#! /usr/bin/env bash
set -euo pipefail

# Install the File Manager fm

sudo pacman -S --needed --asdeps pkgconf gtk4 libadwaita libpanel gtksourceview5 poppler-glib
PKG_CONFIG_PATH="/path/to/libpanel/lib/pkgconfig:$PKG_CONFIG_PATH
yay -S fm-relm4-git

echo "[Done!] Installed the File Manager fm."
