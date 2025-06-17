#!/usr/bin/env bash
set -euo pipefail

# Mount filesystem only

# Set parameters
DISK=/dev/sda
if [[ "$DISK" =~ nvme[0-9]n[0-9]$ ]]; then
  PART_BOOT="${DISK}p1"
else
  PART_BOOT="${DISK}1"
fi
if [[ "$DISK" =~ nvme[0-9]n[0-9]$ ]]; then
  PART_ROOT="${DISK}p2"
else
  PART_ROOT="${DISK}2"
fi
MAPPER_NAME="cryptroot"

BTRFS_OPTS="noatime,compress=zstd,discard=async"
SWAP_OPTS="noatime,compress=no"
SNAPSHOT_OPTS="noatime,compress=zstd"
SUBVOLS=( @home @opt @srv @cache @log @spool @tmp )
MPOINTS=( home opt srv var/cache var/log var/spool tmp )

# Open mapper
read -r -s -p "Enter LUKS passphrase: " L1 < /dev/tty; echo
printf '%s' "$L1" | cryptsetup open --key-file - "$PART_ROOT" "$MAPPER_NAME"
unset L1

export PS4='+ ${BASH_SOURCE:-$0}:${LINENO}: '
set -x

# Mount root
mount -o "${BTRFS_OPTS},subvol=@" "/dev/mapper/${MAPPER_NAME}" /mnt

# Mount subvolumes
for i in "${!SUBVOLS[@]}"; do
  mount -o "${BTRFS_OPTS},subvol=${SUBVOLS[$i]}" "/dev/mapper/${MAPPER_NAME}" "/mnt/${MPOINTS[$i]}"
done

# Mount swap and snapshots
mount -o "${SWAP_OPTS},subvol=@swap" "/dev/mapper/${MAPPER_NAME}" /mnt/swap
mount -o "${SNAPSHOT_OPTS},subvol=@snapshots" "/dev/mapper/${MAPPER_NAME}" /mnt/.snapshots

# Mount ESP
mount "${PART_BOOT}" /mnt/efi

# Activate swapfile
swapon /mnt/swap/swapfile

set +x
echo -e "\033[32m[SUCCESS]\033[0m Filesystem mounted. Chroot manually with \033[31march-chroot /mnt.\033[0m"
