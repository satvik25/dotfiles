#!/bin/bash
# Install packages
set -euo pipefail

# Official packages
OFFICIAL_PACKAGES=(
	"aspell"
	"base-devel"
	"copyq"
	"curl"
	"git"
	"gst-libav"
	"hspell"
	"hunspell"
	"hypridle"
	"hyprland"
	"hyprlock"
	"hyprpolkitagent"
	"hyprsunset"
	"ibus"
	"ibus-typing-booster"
	"iio-sensor-proxy"
	"inotify-tools"
	"intel-media-driver"
	"intel-ucode"
	"iwd"
	"kbd"
	"kitty"
	"lib32-pipewire"
	"libvoikko"
	"mc"
	"mesa"
	"mpd"
	"nftables"
	"noto-fonts"
	"noto-fonts-cjk"
	"noto-fonts-extra"
	"nuspell"
	"openssh"
	"otf-font-awesome"
	"pfetch"
	"pipewire"
	"pipewire-alsa"
	"pipewire-jack"
	"pipewire-pulse"
	"qt5-wayland"
	"swaync"
	"swww"
	"ttf-nerd-fonts-symbols"
	"ttf-opensans"
	"ttf-roboto"
	"udiskie"
	"ufw"
	"uwsm"
	"vulkan-intel"
	"waybar"
	"wireless-regdb"
	"wireplumber"
	"wl-clipboard"
	"xdg-desktop-portal"
	"xdg-desktop-portal-gtk"
	"xdg-desktop-portal-hyprland"
	"yay"
)

# AUR packages
AUR_PACKAGES=(
    "google-chrome"
    "apparmor"
	"hunspell-hi"
	"hyprland-per-window-layout"
	"ibus-m17n"
	"otf-openmoji"
	"preload"
	"ttf-cutive-mono"
	"ttf-ms-fonts"
	"ttf-quicksand-variable"
	"ulauncher-git"
)

# yay
install_aur_helper() {
    if ! command -v yay &> /dev/null; then
        echo "Installing yay AUR helper..."
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        cd /tmp/yay
        makepkg -si --noconfirm
        cd -
        rm -rf /tmp/yay
    fi
}

# Install
sudo pacman -S --noconfirm --needed "${OFFICIAL_PACKAGES[@]}"
install_aur_helper
yay -S --noconfirm --needed "${AUR_PACKAGES[@]}"
