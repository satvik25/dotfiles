#!/usr/bin/env bash
set -euo pipefail
export PS4='+ ${BASH_SOURCE:-$0}:${LINENO}: '
set -x

# Set up snapshots

# Set parameters
MAPPER_NAME="cryptroot"
SNAPSHOT_OPTS="noatime,compress=zstd"

# Mount root and create snapshots subvolume
sudo mkdir /mnt
sudo mount -o subvolid=5 "/dev/mapper/{$MAPPER_NAME}" /mnt
sudo btrfs subvolume create /mnt/@snapshots
sudo umount /mnt

# Mount snapshots subvolume
sudo mkdir -p /.snapshots
sudo mount -o "${SNAPSHOT_OPTS},subvol=@snapshots" "/dev/mapper/{$MAPPER_NAME}" /.snapshots

# Add it to filesystem table     
echo '/dev/mapper/cryptroot /.snapshots btrfs noatime,ssd,compress=zstd,subvol=@snapshots 0 0' \
  | sudo tee -a /etc/fstab

# Set up snapper
sudo snapper -c root create-config /
