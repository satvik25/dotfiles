#!/usr/bin/env bash
# 5-archinstall-mount.sh – create subvolumes, mount filesystem, set up swap
set -euo pipefail

export PS4='+ $(date "+%T") ${BASH_SOURCE}:${LINENO}: '
set -x

DISK=${DISK:-/dev/sda}
if [[ "$DISK" =~ nvme[0-9]n[0-9]$ ]]; then
  PART_BOOT="${DISK}p1"
else
  PART_BOOT="${DISK}1"
fi
MAPPER_NAME="cryptroot"

BTRFS_OPTS="noatime,ssd,compress=zstd,discard=async"
SWAP_OPTS="noatime,ssd,compress=no,space_cache=v2"
SUBVOLS=( @home @opt @srv @cache @log @spool @tmp )
MPOINTS=( home opt srv var/cache var/log var/spool tmp )
SWAP_SIZE=12g

# Create subvolumes
mount "/dev/mapper/${MAPPER_NAME}" /mnt
for subvol in @ "${SUBVOLS[@]}" @swap; do
  btrfs subvolume create "/mnt/${subvol}"
done
umount /mnt

echo -e "\033[32m[SUCCESS]\033[0m Subvolumes created successfully."

# Mount root
mount -o "${BTRFS_OPTS},subvol=@" "/dev/mapper/${MAPPER_NAME}" /mnt

# Create subvolume mountpoints
for mp in "${MPOINTS[@]}" swap; do
  mkdir -p "/mnt/${mp}"
done

# Mount subvolumes
for i in "${!SUBVOLS[@]}"; do
  mount -o "${BTRFS_OPTS},subvol=${SUBVOLS[$i]}" \
        "/dev/mapper/${MAPPER_NAME}" "/mnt/${MPOINTS[$i]}"
done

# Mount swap
mount -o "${SWAP_OPTS},subvol=@swap" \
      "/dev/mapper/${MAPPER_NAME}" /mnt/swap

echo -e "\033[32m[SUCCESS]\033[0m Subvolumes mounted successfully."

# Mount ESP
mount --mkdir "${PART_BOOT}" /mnt/efi

echo -e "\033[32m[SUCCESS]\033[0m ESP mounted successfully."

# Create swapfile
btrfs filesystem mkswapfile --size "${SWAP_SIZE}" --uuid clear /mnt/swap/swapfile
swapon /mnt/swap/swapfile

echo -e "\033[32m[SUCCESS]\033[0m Swapfile activated."
