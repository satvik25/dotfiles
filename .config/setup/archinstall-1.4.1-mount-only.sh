#!/usr/bin/env bash
set -euo pipefail
export PS4='+ ${BASH_SOURCE:-$0}:${LINENO}: '
set -x

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

BTRFS_OPTS="noatime,ssd,compress=zstd,discard=async"
SWAP_OPTS="noatime,ssd,compress=no,space_cache=v2"
SUBVOLS=( @home @opt @srv @cache @log @spool @tmp )
MPOINTS=( home opt srv var/cache var/log var/spool tmp )

# Open mapper
read -r -s -p "Enter LUKS passphrase: " P1 < /dev/tty; echo
printf '%s' "$P1" | cryptsetup open --key-file - "$PART_ROOT" "$MAPPER_NAME"
unset P1

# Mount root
mount -o "${BTRFS_OPTS},subvol=@" "/dev/mapper/${MAPPER_NAME}" /mnt

# Mount subvolumes
for i in "${!SUBVOLS[@]}"; do
  mount -o "${BTRFS_OPTS},subvol=${SUBVOLS[$i]}" "/dev/mapper/${MAPPER_NAME}" "/mnt/${MPOINTS[$i]}"
done

# Mount swap
mount -o "${SWAP_OPTS},subvol=@swap" "/dev/mapper/${MAPPER_NAME}" /mnt/swap

# Mount ESP
mount "${PART_BOOT}" /mnt/efi

# Activate swapfile
swapon /mnt/swap/swapfile

echo -e "\033[32m[SUCCESS]\033[0m Arch installed. Chroot manually with \033[31march-chroot /mnt.\033[0m"
