#! /usr/bin/env bash
set -euo pipefail

# Copy system configuration files

# SDDM
cp -r ~/.local/share/sddm/themes/passage /usr/share/sddm/themes				# Install theme
cp ~/.config/sddm.conf.d/sddm.conf /etc/sddm.conf.d/sddm.conf 			# Set theme
cp -r ~/.local/share/icons/default/ /usr/share/icons						# Set cursor


# GTK
## Set parameters
SCHEMA=org.gnome.desktop.interface
TMPDIR=$(mktemp -d)

SRC="$HOME/.config/environment"
DST="/etc/environment"


## Set preferences
gsettings set $SCHEMA color-scheme 'prefer-dark'								# System light/dark mode
gsettings set $SCHEMA accent-color 'green'										# Accent colour
gsettings set $SCHEMA font-name 'Quicksand Medium 12  @wght=500'				# Interface font
gsettings set $SCHEMA document-font-name 'Quicksand Medium 12 @wght=500'		# Document text font
gsettings set $SCHEMA monospace-font-name 'FiraCode Nerd Font Mono 12'						# Monospace font
gsettings set org.gnome.desktop.interface text-scaling-factor 0.95				# Scaling factor
gsettings set org.gnome.settings-daemon.plugins.xsettings antialiasing 'rgba'	# Anti-aliasing

git clone --depth 1 https://github.com/vinceliuice/Colloid-gtk-theme "$TMPDIR/Colloid-gtk-theme"		# GTK theme
$TMPDIR/Colloid-gtk-theme/install.sh --theme green --color dark --tweaks normal
gsettings set $SCHEMA gtk-theme 'Colloid-Green-Dark'

git clone --depth 1 https://github.com/vinceliuice/Colloid-icon-theme "$TMPDIR/Colloid-icon-theme"		# GTK icon theme
$TMPDIR/Colloid-icon-theme/install.sh --scheme default --theme green
gsettings set $SCHEMA icon-theme 'passage'


# Set cursor
sudo cp -n "$DST" "$DST".bak
sudo awk '
    FNR==NR {        # first file = existing /etc/environment
        if ($0 ~ /[^[:space:]]/) seen[$0]=1
        next
    }
    {
        if ($0 ~ /[^[:space:]]/ && !seen[$0]) print
    }
' "$DST" "$SRC" | sudo tee -a "$DST" >/dev/null
# sudo sh -c "grep -vxFf '$DST' '$SRC' >> '$DST'"							# If awk logic does not works

## Cleanup
rm -rf "$TMPDIR"


# Misc settings
gsettings set org.gnome.desktop.wm.preferences button-layout :
