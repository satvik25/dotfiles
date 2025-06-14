#!/usr/bin/env bash
set -euo pipefail

# Install packages and set up system

echo -e "\033[31mDevice-specific packages:\033[0m intel-ucode"

# List packages
PACKAGES=(
  # Core
  base linux-zen linux-lts linux-firmware intel-ucode
  # Boot & firmware
  grub efibootmgr sbctl
  # Filesystem utilities
  btrfs-progs util-linux
  # Snapshots & monitoring
  snapper grub-btrfs inotify-tools
  # Shell
  zsh terminus-font sudo micro man-db man-pages vlock
  # Other utilities
  brightnessctl playerctl
  # Networking
  reflector iwd networkmanager dnscrypt-proxy wireless-regdb bluez bluez-utils cups
)

# Install packages
pacstrap -K /mnt "${PACKAGES[@]}"

# Generate filesystem table
genfstab -U /mnt >> /mnt/etc/fstab

echo -e "\033[32m[SUCCESS]\033[0m Arch installed. Chroot manually with \033[31march-chroot /mnt.\033[0m"
