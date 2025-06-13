#!/usr/bin/env bash
# Secure Boot setup
set -euo pipefail
export PS4='+ ${BASH_SOURCE:-$0}:${LINENO}: '
set -x

sbctl create-keys
sbctl enroll-keys -m

sbctl sign -s /boot/vmlinuz-linux-zen
sbctl sign -s /boot/vmlinuz-linux-lts
sbctl sign -s /efi/EFI/GRUB/grubx64.efi

# Create UEFI known path for bootloader (esp. on DELL laptops)
mkdir -p /efi/EFI/BOOT
cp /efi/EFI/GRUB/grubx64.efi /efi/EFI/BOOT/BOOTX64.EFI

echo -e "\033[32m[SUCCESS]\033[0m Secure Boot set."
