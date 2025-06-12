#!/usr/bin/env bash
# 9-secureboot.sh - Secure Boot installer
set -euo pipefail
export PS4='+ ${BASH_SOURCE:-$0}:${LINENO}: '
set -x

# 7. Setup sbctl for Secure Boot key management
sbctl create-keys
sbctl enroll-keys -m

echo "sbctl keys created and enrolled."

# 8. Sign kernel and GRUB EFI binary for Secure Boot
# Sign vmlinuz-linux
  sbctl sign -s /boot/vmlinuz-linux-zen
  sbctl sign -s /boot/vmlinuz-linux-lts
  sbctl sign -s /efi/EFI/GRUB/grubx64.efi

# 9. Create fallback boot path
mkdir -p /efi/EFI/BOOT
cp /efi/EFI/GRUB/grubx64.efi /efi/EFI/BOOT/BOOTX64.EFI

echo "Copied GRUB EFI to fallback BOOTX64.EFI."

echo "GRUB + Secure Boot configuration complete."
