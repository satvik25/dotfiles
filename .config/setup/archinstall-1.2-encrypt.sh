#!/usr/bin/env bash
set -euo pipefail
export PS4='+ ${BASH_SOURCE:-$0}:${LINENO}: '
set -x

# Encrypt root partition

# Set parameters
DISK=/dev/sda
if [[ "$DISK" =~ nvme[0-9]n[0-9]$ ]]; then
  PART_ROOT="${DISK}p2"
else
  PART_ROOT="${DISK}2"
fi
MAPPER_NAME=cryptroot
LABEL_ROOT=ROOTFS

# Abort if the device is already mapped
if lsblk -no NAME | grep -q "^${MAPPER_NAME}$"; then
  echo "[ERROR] /dev/mapper/${MAPPER_NAME} already exists. Close it first (cryptsetup close ${MAPPER_NAME})." >&2
  exit 1
fi

# Read and confirm passphrase
while true; do
  read -r -s -p "Enter new LUKS passphrase: " L1 < /dev/tty; echo
  read -r -s -p "Confirm passphrase: "         L2 < /dev/tty; echo
  [[ "$L1" == "$L2" && -n "$L1" ]] && break
  echo "Passphrases didn’t match" >&2
done

# Encrypt & open mapper
printf '%s' "$L1" | \
  cryptsetup luksFormat --batch-mode --type luks2 --pbkdf pbkdf2 \
    --label "$LABEL_ROOT" --key-file - "$PART_ROOT"

printf '%s' "$L1" | \
  cryptsetup open --key-file - "$PART_ROOT" "$MAPPER_NAME"

# Clear passphrase from memory
unset L1 L2

echo -e "\033[32m[SUCCESS]\033[0m $PART_ROOT encrypted. Available at /dev/mapper/${MAPPER_NAME}."
