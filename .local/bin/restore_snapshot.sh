#!/usr/bin/env bash
set -euo pipefail

# Restore system from snapshot
# Usage: GRUB > Snapshots sub-menu > Choose snapshot > sudo ./.local/bin/restore_snapshot.sh

# Check root status
if [[ $EUID -ne 0 ]]; then
  echo "Run with sudo." >&2
  exit 1
fi

# Get current snapshot number
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
    read -rp "Enter the snapshot number you want to restore: " SNAP_NUM
  fi
else
  read -rp "Enter the snapshot number you want to restore: " SNAP_NUM
fi

echo "Selected snapshot: $SNAP_NUM"

# Determine btrfs device
DEV=${DEV_RAW%%[*}
# echo "Using btrfs device: $DEV"

# Mount top-level
MNT="/tmp/btrfs"
mkdir -p "$MNT"
mount -o subvolid=0 "$DEV" "$MNT"

# Ask whether to backup current @
read -rp "Backup current root subvolume @? [y/N]: " BACKUP_ANSWER
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

# Get the subvolume ID of the chosen snapshot
SNAP_ID=$(btrfs subvolume list "$MNT" | awk -v path="@snapshots/$SNAP_NUM/snapshot" '$0 ~ path {print $2}')
echo "Snapshot ID: $SNAP_ID"

# Set snapshot as default subvolume temporarily so old root @ could be deleted
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



# Always back up .snapshots separately to avoid loss after rollback
SNAPSHOTS_BAK_NAME=".snapshots-bak-$(date +%F-%H%M%S)"
if [[ -d "$MNT/@/.snapshots" ]]; then
  echo "Backing up .snapshots as $SNAPSHOTS_BAK_NAME"
  mv "$MNT/@/.snapshots" "$MNT/$SNAPSHOTS_BAK_NAME"
else
  echo "No .snapshots directory found in current @"
fi


# Delete old root subvolume @
echo "Deleting old root subvolume @"
btrfs subvolume delete "$MNT/@"

# Recreate @ from the chosen snapshot
echo "Recreating @ from snapshot $SNAP_NUM"
btrfs subvolume snapshot "$SNAP_PATH" "$MNT/@"



# Restore the .snapshots directory if backup exists
if [[ -d "$MNT/$SNAPSHOTS_BAK_NAME" ]]; then
  echo "Restoring .snapshots directory to new @"
  mv "$MNT/$SNAPSHOTS_BAK_NAME" "$MNT/@/.snapshots"
else
  echo "No .snapshots backup found to restore"
fi



# Set default to the new @
NEW_ID=$(btrfs subvolume list "$MNT" | awk '/ path @$/ {print $2}')
echo "New '@' subvolume ID: $NEW_ID"
btrfs subvolume set-default "$NEW_ID" "$MNT"

# Cleanup
umount "$MNT"
rmdir "$MNT"

echo -e "\033[32m[Restore complete.]\033[0m System reset to snapshot \033[32m$SNAP_NUM\033[0m. Takes effect on next reboot."
echo -e "Preferable to regenerate GRUB config (with \033[31mupdate-grub\033[0m) on next reboot."
