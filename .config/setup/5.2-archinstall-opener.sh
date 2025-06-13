#!/usr/bin/env bash
set -euo pipefail

DISK=/dev/sda
if [[ "$DISK" =~ nvme[0-9]n[0-9]$ ]]; then
  PART_ROOT="${DISK}p2"
else
  PART_ROOT="${DISK}2"
fi
MAPPER_NAME="cryptroot"

# If it’s already open, bail out
if [ -e "/dev/mapper/${MAPPER_NAME}" ]; then
  echo "✖ /dev/mapper/${MAPPER_NAME} is already open."
  exit 1
fi

# Prompt for passphrase (no echo)
read -r -s -p "Enter new LUKS passphrase: " L1 < /dev/tty; echo

# Open the encrypted device
printf '%s' "$L1" | \
  cryptsetup open --key-file - "$PART_ROOT" "$MAPPER_NAME"

# Clear passphrase variable from memory
unset PASS

echo "✔ Opened ${DEVICE} as /dev/mapper/${MAPPER_NAME}"
