#!/bin/bash
set -euo pipefail

# Install packages

# Official packages
OFFICIAL_PACKAGES=(
 	# Video (Drivers)
  	intel-media-driver libva-intel-driver mesa vulkan-intel \
   	# Audio
 	pipewire wireplumber pipewire-pulse easyeffects lsp-plugins\
	# Battery
	acpi tlp \
  	# Security
   	ufw nftables bitwarden-cli clamav lynis proton-vpn-gtk-app \
	#DE
	hyprland hyprpolkitagent hypridle hyprlock hyprsunset \
	uwsm qt5-wayland qt6-wayland waybar swww swaync sddm \
 	xdg-desktop-portal xdg-desktop-portal-hyprland xdg-desktop-portal-gtk \
    wl-clipboard copyq \
    grim slurp \
	udiskie \
	osdlyrics \
	# Touchscreen
	iio-sensor-proxy iio-hyprland nwg-drawer sqeekboard \
	# Utilities
 	jq wget kitty inxi 7z mc nemo gthumb thunderbird rclone fd fzf \
	# Office
	evince libreoffice-fresh \
   	# Fonts
  	noto-fonts noto-fonts-cjk noto-fonts-extra \
	otf-font-awesome ttf-firacode-nerd ttf-nerd-fonts-symbols ttf-opensans ttf-roboto \
	ebgaramond-otf \
    # Language
 	ibus ibus-typing-booster aspell hunspell hunspell-en_gb hspell nuspell libvoikko \
    # Development
 	base-devel git openssh \
 	# Theming
 	gnome-tweaks lxappearance dconf-editor qt6ct kvantum
 	# Extras
	# gst-libav pipewire-alsa pipewire-jack lib32-pipewire
)

# Dependency packages
DEPS_PACKAGES=(
	# Nemo File Manager
	python-pillow \
	# Ulauncher extns
	# python-pip
	## Ulauncher extn: Calculate Anything
	python-pint python-parsedatetime python-pytz \
	# Hyprland plugins
	cpio cmake git meson gcc \
	# Colloid GTK Theme
	gnome-themes-extra gtk-engine-murrine \
	# librepods
	qt6-base qt6-connectivity qt6-multimedia-ffmpeg qt6-multimedia	
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
 	hyprshot-git hyprshot-gui \
 	packet \
 	libinput-gestures \
 	pyprland \
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
	python-simpleeval \
	# packet: Optional
	python-dbus nautilus-python \
	# Hyprland plugin deps
	glm
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
echo -e "\033[33mBuild the following packages manually:\033[0m"
echo "librepods \nadd-more-here"
