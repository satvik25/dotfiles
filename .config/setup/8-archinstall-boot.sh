#!/usr/bin/env bash
# 8-archinstall-boot.sh - Boot Setup
set -euo pipefail
export PS4='+ ${BASH_SOURCE:-$0}:${LINENO}: '
set -x

# 1. Get the UUID of the root partition (unencrypted)
root_uuid=$(blkid -s UUID -o value /dev/sda2)
# 2. Get the UUID of the cryptroot device
crypt_uuid=$(blkid -s UUID -o value /dev/mapper/cryptroot)
# 3. Get the resume offset of the swapfile
offset=$(btrfs inspect-internal map-swapfile -r /swap/swapfile | awk '/offset/ {print $2}')
# 4. In-place edit of /etc/default/grub to enable cryptodisk and set boot parameters
# Uncomment or set GRUB_ENABLE_CRYPTODISK
sed -i 's/^#\?GRUB_ENABLE_CRYPTODISK=.*/GRUB_ENABLE_CRYPTODISK=y/' /etc/default/grub
# Update GRUB_CMDLINE_LINUX_DEFAULT with encryption, root, resume & performance options
sed -i 's|^#\?GRUB_CMDLINE_LINUX_DEFAULT=.*|GRUB_CMDLINE_LINUX_DEFAULT="cryptdevice=UUID='$root_uuid':cryptroot:allow-discards root=/dev/mapper/cryptroot resume=UUID='$crypt_uuid' resume_offset='$offset' zswap.enabled=1 loglevel=3 quiet"|' /etc/default/grub
# Ensure GRUB_CMDLINE_LINUX is defined (empty if not present)
grep -q '^GRUB_CMDLINE_LINUX=' /etc/default/grub || echo 'GRUB_CMDLINE_LINUX=""' >> /etc/default/grub

echo "/etc/default/grub updated in-place with encrypted root configuration."

# 5. Install GRUB EFI with TPM module, disable shim lock
grub-install \
  --target=x86_64-efi \
  --efi-directory=/efi \
  --bootloader-id=GRUB \
  --modules="tpm" \
  --disable-shim-lock

echo "GRUB EFI installed with TPM support."

# 6. Generate GRUB config
grub-mkconfig -o /boot/grub/grub.cfg

echo "Generated /boot/grub/grub.cfg."
