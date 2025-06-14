#!/usr/bin/env bash
set -euo pipefail
export PS4='+ ${BASH_SOURCE:-$0}:${LINENO}: '
set -x

# Basic system setup

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
while true; do
    read -s -p "Enter new root password: " P1 < /dev/tty; echo
    read -s -p "Confirm root password: " P2 < /dev/tty; echo

    if [[ "$P1" == "$P2" ]]; then
        break
    else
        echo "Passwords do not match. Try again." > /dev/tty
    fi
done

passwd root < <(printf "%s\n%s\n" "$P1" "$P1")

# 32-bit Repos
sed -i '/^\s*#\s*\[multilib\]/,/^$/{s/^\s*#\s*//}' /etc/pacman.conf

# Wireless Regulatory Domain
sed -i 's/^#\?\s*WIRELESS_REGDOM=.*/WIRELESS_REGDOM="IN"/' /etc/conf.d/wireless-regdom

# Regenerate initramfs
mkinitcpio -P

echo -e "\033[32m[SUCCESS]\033[0m System set up."
