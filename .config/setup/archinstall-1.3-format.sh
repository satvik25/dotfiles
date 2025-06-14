#!/usr/bin/env bash
set -euo pipefail

# Format partitions

# Set parameters
DISK=/dev/sda
if [[ "$DISK" =~ nvme[0-9]n[0-9]$ ]]; then
  PART_BOOT="${DISK}p1"
else
  PART_BOOT="${DISK}1"
fi
MAPPER_NAME=cryptroot
LABEL_BOOT=BOOTFS
LABEL_CONTAINER=LUKS_ROOT

# Format ESP
mkfs.fat -F 32 -n "$LABEL_BOOT" "$PART_BOOT"

# Format root partition
mkfs.btrfs -L "$LABEL_CONTAINER" /dev/mapper/${MAPPER_NAME}

echo -e "\033[32m[SUCCESS]\033[0m $DISK formatted successfully."
