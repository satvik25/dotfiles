#!/usr/bin/env bash
# restore_snapshot.sh - Roll back current root to a specified Btrfs/Snapper snapshot
# Usage: Run this script from any booted snapshot (with sudo or as root).

set -euo pipefail

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root. Use sudo or run as root." >&2
  exit 1
fi

# Determine current snapshot number from mount
DEV_RAW=$(findmnt -no SOURCE /)
if [[ "$DEV_RAW" =~ @snapshots/([0-9]+)/snapshot ]]; then
  CUR_SNAP=${BASH_REMATCH[1]}
else
  CUR_SNAP=""
fi

# Ask whether to restore from current booted snapshot or another
if [[ -n "$CUR_SNAP" ]]; then
  read -rp "Restore from current booted snapshot $CUR_SNAP? [Y/n]: " USE_CUR
  if [[ ! "$USE_CUR" =~ ^[Nn]$ ]]; then
    SNAP_NUM=$CUR_SNAP
  else
    read -rp "Enter the Snapper snapshot number you want to restore: " SNAP_NUM
  fi
else
  read -rp "Enter the Snapper snapshot number you want to restore: " SNAP_NUM
fi

echo "Selected snapshot: $SNAP_NUM"

# Determine Btrfs device (strip any mount options suffix)
DEV=${DEV_RAW%%[*}
echo "Using Btrfs device: $DEV"

# Mount top-level
MNT="/tmp/btrfs"
mkdir -p "$MNT"
mount -o subvolid=0 "$DEV" "$MNT"

# Ask whether to backup current @
read -rp "Do you want to backup the current root subvolume '@'? [y/N]: " BACKUP_ANSWER
if [[ "$BACKUP_ANSWER" =~ ^[Yy]$ ]]; then
  BACKUP_NAME="@oldroot-$(date +%F-%H%M)"
  echo "Creating safety backup of current @ as $BACKUP_NAME"
  btrfs subvolume snapshot "$MNT/@" "$MNT/$BACKUP_NAME"
else
  echo "Skipping backup of current @"
fi

# Verify snapshot exists
SNAP_PATH="$MNT/@snapshots/$SNAP_NUM/snapshot"
if [[ ! -d "$SNAP_PATH" ]]; then
  echo "Snapshot path not found: $SNAP_PATH" >&2
  umount "$MNT" && rmdir "$MNT"
  exit 1
fi

# Find the subvolume ID of the chosen snapshot
SNAP_ID=$(btrfs subvolume list "$MNT" | awk -v path="@snapshots/$SNAP_NUM/snapshot" '$0 ~ path {print $2}')
echo "Snapshot ID: $SNAP_ID"

# Point default to snapshot
echo "Setting default subvolume to snapshot $SNAP_ID"
btrfs subvolume set-default "$SNAP_ID" "$MNT"

# Delete subvolumes inside old root @ so it could be deleted
ROOT="/tmp/btrfs/@"
SUBVOLS=(
  "$ROOT/var/lib/portables"
  "$ROOT/var/lib/machines"
)
for subvol in "${SUBVOLS[@]}"; do
    if btrfs subvolume show "$subvol" &>/dev/null; then
        echo "Deleting subvolume: $subvol"
        btrfs subvolume delete "$subvol"
    else
        echo "No subvolume found at: $subvol"
    fi
done

# Delete old root subvolume '@'
echo "Deleting old root subvolume '@'"
btrfs subvolume delete "$MNT/@"

# Recreate @ from the chosen snapshot
echo "Recreating @ from snapshot $SNAP_NUM"
btrfs subvolume snapshot "$SNAP_PATH" "$MNT/@"

# Set default to the new '@'
NEW_ID=$(btrfs subvolume list "$MNT" | awk '/ path @$/ {print $2}')
echo "New '@' subvolume ID: $NEW_ID"
btrfs subvolume set-default "$NEW_ID" "$MNT"

# Cleanup
umount "$MNT"
rmdir "$MNT"

# Regenerate GRUB configuration
echo "Regenerating GRUB configuration"
grub-mkconfig -o /boot/grub/grub.cfg

echo "Restore complete. System reset to snapshot $SNAP_NUM. Takes effect on next reboot."
