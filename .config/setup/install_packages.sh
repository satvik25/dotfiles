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
    "base-devel"
    "git"
    "firefox"
    "neovim"
)

# AUR packages
AUR_PACKAGES=(
    "google-chrome"
    "visual-studio-code-bin"
    "spotify"
)

# Install official packages
echo "Installing official packages..."
sudo pacman -S --noconfirm --needed "${OFFICIAL_PACKAGES[@]}"

# Install AUR helper
install_aur_helper

# Install AUR packages
echo "Installing AUR packages..."
yay -S --noconfirm --needed "${AUR_PACKAGES[@]}"
