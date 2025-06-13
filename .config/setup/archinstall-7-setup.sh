#!/usr/bin/env bash
# Basic system setup
set -euo pipefail
export PS4='+ ${BASH_SOURCE:-$0}:${LINENO}: '
set -x

# Time
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc
timedatectl set-ntp true
# Language
echo "LANG=en_GB.UTF-8" > /etc/locale.conf
sed -i '/^#\s*en_GB.UTF-8 UTF-8/s/^#//' /etc/locale.gen
locale-gen
# Font
echo "FONT=ter-120n" > /etc/vconsole.conf
# Hostname
echo "arch" > /etc/hostname

# Root Password
# Read Password
while true; do
    read -s -p "Enter new root password: " ROOT1 < /dev/tty; echo
    read -s -p "Confirm root password: " ROOT2 < /dev/tty; echo

    if [[ "$ROOT1" == "$ROOT2" ]]; then
        break
    else
        echo "Passwords do not match. Try again." > /dev/tty
    fi
done
# Set Password
passwd root < <(printf "%s\n%s\n" "$ROOT1" "$ROOT1")

# 32-bit Repos
sed -i '/^\s*#\s*\[multilib\]/,/^$/{s/^\s*#\s*//}' /etc/pacman.conf
# Wireless Regulatory Domain
sed -i 's/^#\?\s*WIRELESS_REGDOM=.*/WIRELESS_REGDOM="IN"/' /etc/conf.d/wireless-regdom
# Regenerate initramfs
mkinitcpio -P

echo -e "\033[32m[SUCCESS]\033[0m System set up."
