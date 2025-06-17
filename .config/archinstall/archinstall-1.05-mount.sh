#!/usr/bin/env bash
set -euo pipefail
export PS4='+ ${BASH_SOURCE:-$0}:${LINENO}: '
set -x

# Create subvolumes, mount filesystem, set up swap

# Set parameters
DISK=/dev/sda
if [[ "$DISK" =~ nvme[0-9]n[0-9]$ ]]; then
  PART_BOOT="${DISK}p1"
else
  PART_BOOT="${DISK}1"
fi
MAPPER_NAME="cryptroot"

BTRFS_OPTS="noatime,compress=zstd,discard=async"
SWAP_OPTS="noatime,compress=no"
SNAPSHOT_OPTS="noatime,compress=zstd"
SUBVOLS=( @home @opt @srv @cache @log @spool @tmp )
MPOINTS=( home opt srv var/cache var/log var/spool tmp )
SWAP_SIZE=12g

# Create subvolumes
mount "/dev/mapper/${MAPPER_NAME}" /mnt
for subvol in @ "${SUBVOLS[@]}" @swap @snapshots; do
  btrfs subvolume create "/mnt/${subvol}"
done
umount /mnt

set +x
echo -e "\033[32m[SUCCESS]\033[0m Subvolumes created."
set -x

# Mount root
mount -o "${BTRFS_OPTS},subvol=@" "/dev/mapper/${MAPPER_NAME}" /mnt

# Create subvolume mountpoints
for mp in "${MPOINTS[@]}" swap .snapshots; do
  mkdir -p "/mnt/${mp}"
done

# Mount subvolumes
for i in "${!SUBVOLS[@]}"; do
  mount -o "${BTRFS_OPTS},subvol=${SUBVOLS[$i]}" "/dev/mapper/${MAPPER_NAME}" "/mnt/${MPOINTS[$i]}"
done

# Mount swap and snapshots
mount -o "${SWAP_OPTS},subvol=@swap" "/dev/mapper/${MAPPER_NAME}" /mnt/swap
mount -o "${SNAPSHOT_OPTS},subvol=@snapshots" "/dev/mapper/${MAPPER_NAME}" /mnt/.snapshots

set +x
echo -e "\033[32m[SUCCESS]\033[0m Subvolumes mounted."
set -x

# Mount ESP
mount --mkdir "${PART_BOOT}" /mnt/efi

set +x
echo -e "\033[32m[SUCCESS]\033[0m ESP mounted."
set -x

# Create swapfile
btrfs filesystem mkswapfile --size "${SWAP_SIZE}" --uuid clear /mnt/swap/swapfile
swapon /mnt/swap/swapfile

set +x
echo -e "\033[32m[SUCCESS]\033[0m Swapfile activated."
