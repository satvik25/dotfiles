#!/usr/bin/env bash
# 8-archinstall-setup.sh - Bootloader Setup
set -euo pipefail
export PS4='+ ${BASH_SOURCE:-$0}:${LINENO}: '
set -x

# 1. Get the UUID of the root partition (unencrypted)
root_uuid=$(blkid -s UUID -o value /dev/sda2)
# 2. Get the UUID of the cryptroot device
crypt_uuid=$(blkid -s UUID -o value /dev/mapper/cryptroot)
# 3. Get the resume offset of the swapfile
offset=$(btrfs inspect-internal map-swapfile -r /swap/swapfile | awk '/offset/ {print $2}')

# 4. Update /etc/default/grub inside the chroot
cat > /etc/default/grub <<EOF
# /etc/default/grub: GRUB bootloader configuration
GRUB_DEFAULT=0
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/lsb-release 2>/dev/null || echo Arch)"
GRUB_ENABLE_CRYPTODISK=y
GRUB_CMDLINE_LINUX_DEFAULT="cryptdevice=UUID=$root_uuid:cryptroot:allow-discards \
    root=/dev/mapper/cryptroot \
    resume=UUID=$crypt_uuid resume_offset=$offset \
    zswap.enabled=1 loglevel=3 quiet"
GRUB_CMDLINE_LINUX=""
EOF

echo "/etc/default/grub updated with encrypted root + cryptodisk enabled."

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
