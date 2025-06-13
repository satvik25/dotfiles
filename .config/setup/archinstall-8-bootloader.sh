#!/usr/bin/env bash
# Bootloader setup
set -euo pipefail
export PS4='+ ${BASH_SOURCE:-$0}:${LINENO}: '
set -x

root_uuid=$(blkid -s UUID -o value /dev/sda2)
crypt_uuid=$(blkid -s UUID -o value /dev/mapper/cryptroot)
# [FIX ATTEMPTED] Check if offset is getting printed. Rewrite this line if not.
offset=$(btrfs inspect-internal map-swapfile -r /swap/swapfile)

# Set parameters
sed -i 's/^#\?GRUB_ENABLE_CRYPTODISK=.*/GRUB_ENABLE_CRYPTODISK=y/' /etc/default/grub
# Notify GRUB of encryption, resume & performance options
sed -i 's|^#\?GRUB_CMDLINE_LINUX_DEFAULT=.*|GRUB_CMDLINE_LINUX_DEFAULT="cryptdevice=UUID='$root_uuid':cryptroot:allow-discards root=/dev/mapper/cryptroot resume=UUID='$crypt_uuid' resume_offset='$offset' zswap.enabled=1 loglevel=3 quiet"|' /etc/default/grub

echo -e "\033[32m[SUCCESS]\033[0m GRUB config updated."

# Install GRUB
grub-install \
  --target=x86_64-efi \
  --efi-directory=/efi \
  --bootloader-id=GRUB \
  --modules="tpm" \
  --disable-shim-lock
grub-mkconfig -o /boot/grub/grub.cfg

echo -e "\033[32m[SUCCESS]\033[0m GRUB installed."
