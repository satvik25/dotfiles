#!/usr/bin/env bash
set -euo pipefail
export PS4='+ ${BASH_SOURCE:-$0}:${LINENO}: '
set -x

# Bootloader setup

# Set parameters
root_uuid=$(blkid -s UUID -o value /dev/sda2)
# crypt_uuid=$(blkid -s UUID -o value /dev/mapper/cryptroot)
offset_val=$(btrfs inspect-internal map-swapfile -r /swap/swapfile)

# Update GRUB options
sed -i 's/^#\?GRUB_ENABLE_CRYPTODISK=.*/GRUB_ENABLE_CRYPTODISK=y/' /etc/default/grub
## Cosmetic options
sed -i 's/^#\?GRUB_TIMEOUT=.*/GRUB_TIMEOUT=3/' /etc/default/grub
sed -i 's/^#\?GRUB_TIMEOUT_STYLE=.*/GRUB_TIMEOUT_STYLE=hidden/' /etc/default/grub

sed -i '/^#\?GRUB_CMDLINE_LINUX_DEFAULT=/c\
GRUB_CMDLINE_LINUX_DEFAULT="cryptdevice=UUID='"$root_uuid"':cryptroot:allow-discards root=/dev/mapper/cryptroot \\\
resume=/dev/mapper/cryptroot resume_offset='"$offset_val"' \\\
zswap.enabled=1 \\\
loglevel=3 quiet splash"' \
/etc/default/grub

set +x
echo -e "\033[32m[SUCCESS]\033[0m GRUB config updated."
set -x

# Install GRUB
grub-install \
  --target=x86_64-efi \
  --efi-directory=/efi \
  --bootloader-id=GRUB \
  --modules="tpm" \
  --disable-shim-lock

# Generate GRUB config
grub-mkconfig -o /boot/grub/grub.cfg

set +x
echo -e "\033[32m[SUCCESS]\033[0m GRUB installed."
