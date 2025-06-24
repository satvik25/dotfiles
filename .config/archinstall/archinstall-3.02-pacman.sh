#!/bin/bash
set -euo pipefail

# Install packages

# Official packages
OFFICIAL_PACKAGES=(
 	# Video (Drivers)
  	intel-media-driver libva-intel-driver mesa vulkan-intel \
   	# Audio
 	pipewire wireplumber pipewire-pulse \
  	# Security
   	ufw nftables \
	#DE
	hyprland hyprpolkitagent hypridle hyprlock hyprsunset \
	uwsm qt5-wayland qt6-wayland waybar swww swaync sddm \
 	xdg-desktop-portal xdg-desktop-portal-hyprland xdg-desktop-portal-gtk \
    wl-clipboard copyq \
	udiskie \
	# Utilities
 	kitty mc 7z jq \
   	# Fonts
  	noto-fonts noto-fonts-cjk noto-fonts-extra \
	otf-font-awesome ttf-nerd-fonts-symbols ttf-opensans ttf-roboto \
    	# Language
 	ibus ibus-typing-booster aspell hunspell hspell nuspell libvoikko \
     	# Development
 	base-devel git openssh
 	# Extras
 	# gst-libav pipewire-alsa pipewire-jack lib32-pipewire iio-sensor-proxy mpd
)

# Dependency packages
DEPS_PACKAGES=(
	# Ulauncher extns
	# python-pip
	# Ulauncher extn: Calculate Anything
	python-pint python-parsedatetime python-pytz \
	# Hyprland plugins
	cpio cmake git meson gcc
)

# AUR packages
AUR_PACKAGES=(
	# Fonts
 	ttf-cutive-mono ttf-quicksand-variable ttf-ms-fonts otf-openmoji \
  	# Language
   	ibus-m17n hunspell-hi \
  	# Security
  	apparmor \
   	# DE
    	hyprland-per-window-layout ulauncher-git \
  	# Browser
   	google-chrome \
	# Utilities
 	pfetch arch-update
 	# Extras
 	# preload
)

# Dependency AUR packages
DEPS_AUR_PACKAGES=(
	# Ulauncher extn: Calculate Anything
	python-simpleeval
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
sudo pacman -Syu --noconfirm
sudo pacman -S --noconfirm --needed "${OFFICIAL_PACKAGES[@]}"
sudo pacman -S --noconfirm --needed --asdeps "${DEPS_PACKAGES[@]}"
install_aur_helper
yay -S --noconfirm --needed "${AUR_PACKAGES[@]}"
yay -S --noconfirm --needed --asdeps "${DEPS_AUR_PACKAGES[@]}"

echo -e "\033[32m[SUCCESS]\033[0m Packages installed."
