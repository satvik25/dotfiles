#!/usr/bin/env bash
set -euo pipefail
export PS4='+ ${BASH_SOURCE:-$0}:${LINENO}: '
set -x

# Set up snapshots

# Set parameters
DISK=/dev/sda
if [[ "$DISK" =~ nvme[0-9]n[0-9]$ ]]; then
  PART_BOOT="${DISK}p1"
else
  PART_BOOT="${DISK}1"
fi
MAPPER_NAME="cryptroot"

sudo mkdir /mnt
sudo mount -o subvolid=5 /dev/mapper/cryptroot /mnt
sudo btrfs subvolume create /mnt/@snapshots
sudo umount /mnt
sudo mkdir -p /.snapshots
sudo mount -o noatime,ssd,compress=zstd,subvol=@snapshots \
     /dev/mapper/cryptroot /.snapshots
     
echo '/dev/mapper/cryptroot /.snapshots btrfs noatime,ssd,compress=zstd,subvol=@snapshots 0 0' \
  | sudo tee -a /etc/fstab

sudo snapper -c root create-config /
