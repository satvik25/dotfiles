#!/usr/bin/env bash
# 4-archinstall-format.sh - format partitions
set -euo pipefail

DISK=/dev/sda
if [[ "$DISK" =~ nvme[0-9]n[0-9]$ ]]; then
  PART="${DISK}p1"
else
  PART="${DISK}1"
fi
MAPPER_NAME=cryptroot
LABEL_BOOT=BOOTFS
LABEL_CONTAINER=LUKS_ROOT

# Format the EFI System Partition (ESP)
mkfs.fat -F 32 -n "$LABEL_BOOT" "$PART"

# Format the decrypted LUKS container as Btrfs
mkfs.btrfs -L "$LABEL_CONTAINER" /dev/mapper/${MAPPER_NAME}

echo "Disk formatted successfully."
