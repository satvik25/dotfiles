#!/usr/bin/env bash
set -euo pipefail

DEVICE="/dev/sda2"
MAPPER_NAME="cryptroot"

# If it’s already open, bail out
if [ -e "/dev/mapper/${MAPPER_NAME}" ]; then
  echo "✖ /dev/mapper/${MAPPER_NAME} is already open."
  exit 1
fi

# Prompt for passphrase (no echo)
read -r -s -p "Enter LUKS passphrase for ${DEVICE}: " PASS < /dev/tty
echo

# Open the encrypted device
printf '%s\n' "$PASS" \
  | cryptsetup open -d - "$DEVICE" "$MAPPER_NAME"

# Clear passphrase variable from memory
unset PASS

echo "✔ Opened ${DEVICE} as /dev/mapper/${MAPPER_NAME}"
