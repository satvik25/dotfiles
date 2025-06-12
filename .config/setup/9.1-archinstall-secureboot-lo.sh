#!/usr/bin/env bash
# 7-archinstall-setup.sh - Basic System Setup
set -euo pipefail
export PS4='+ ${BASH_SOURCE:-$0}:${LINENO}: '
set -x

# Sign GRUB EFI binary
  sbctl sign -s /efi/EFI/GRUB/grubx64.efi
  echo "Signed /efi/EFI/GRUB/grubx64.efi."
else
  echo "Warning: grubx64.efi not found, skipping." >&2
fi

# 9. Create fallback boot path
mkdir -p /efi/EFI/BOOT
cp /efi/EFI/GRUB/grubx64.efi /efi/EFI/BOOT/BOOTX64.EFI

echo "Copied GRUB EFI to fallback BOOTX64.EFI."

echo "GRUB + Secure Boot configuration complete."
