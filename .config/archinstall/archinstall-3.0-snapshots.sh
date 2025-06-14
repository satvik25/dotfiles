#!/usr/bin/env bash
set -euo pipefail
export PS4='+ ${BASH_SOURCE:-$0}:${LINENO}: '
set -x

# Set up snapshots

# Set parameters
MAPPER_NAME="cryptroot"
SNAPSHOT_OPTS="noatime,compress=zstd,subvol=@snapshots"

# Check root status
(( EUID == 0 )) || exec sudo -- "$0" "$@"

# Mount root and create snapshots subvolume
mkdir -p /mnt
mount -o subvolid=5 "/dev/mapper/${MAPPER_NAME}" /mnt
btrfs subvolume create /mnt/@snapshots
umount /mnt

# Mount snapshots subvolume
mkdir -p /.snapshots
mount -o "${SNAPSHOT_OPTS}" "/dev/mapper/${MAPPER_NAME}" /.snapshots

# Add it to filesystem table     
echo "/dev/mapper/cryptroot /.snapshots btrfs "${SNAPSHOT_OPTS}" 0 0" \
  | tee -a /etc/fstab

# Set up snapper
snapper -c root create-config /
