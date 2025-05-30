#!/bin/bash

# Install yay if not present
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

# Official packages
OFFICIAL_PACKAGES=(
	"aspell"
	"base"
	"base-devel"
	"bluez"
	"bluez-utils"
	"brightnessctl"
	"btrfs-progs"
	"copyq"
	"cups"
	"curl"
	"dnscrypt-proxy"
	"efibootmgr"
	"git"
	"grub-btrfs"
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
	"linux-firmware"
	"linux-lts"
	"linux-zen"
	"man-db"
	"man-pages"
	"mc"
	"mesa"
	"micro"
	"mpd"
	"networkmanager"
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
	"reflector"
	"snapper"
	"sudo"
	"swaync"
	"swww"
	"ttf-nerd-fonts-symbols"
	"ttf-opensans"
	"ttf-roboto"
	"udiskie"
	"ufw"
	"util-linux"
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
	"zsh"
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

# Install official packages
echo "Installing official packages..."
sudo pacman -S --noconfirm --needed "${OFFICIAL_PACKAGES[@]}"

# Install AUR helper
install_aur_helper

# Install AUR packages
echo "Installing AUR packages..."
yay -S --noconfirm --needed "${AUR_PACKAGES[@]}"
