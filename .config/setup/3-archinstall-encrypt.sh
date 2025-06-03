#!/usr/bin/env bash
# 3-archinstall-encrypt.sh
# Encrypts the target partition with LUKS2 using the PBKDF2 key-derivation method
# and opens it as /dev/mapper/cryptroot.
#
# Usage: sudo ./3-archinstall-encrypt.sh
#
# Environment variables (optional overrides):
#   DEVICE       – block device to encrypt (default: /dev/sda2)
#   MAPPER_NAME  – name for the opened mapper (default: cryptroot)

set -euo pipefail

DEVICE="${DEVICE:-/dev/sda2}"
MAPPER_NAME="${MAPPER_NAME:-cryptroot}"

# Abort if the device is already mapped
if lsblk -no NAME | grep -q "^${MAPPER_NAME}$"; then
  echo "[ERROR] /dev/mapper/${MAPPER_NAME} already exists. Close it first (cryptsetup close ${MAPPER_NAME})." >&2
  exit 1
fi

# Read and confirm passphrase
while true; do
  read -rsp "Enter passphrase for ${DEVICE}: " pass1; echo
  read -rsp "Confirm passphrase: " pass2; echo
  if [[ -z "$pass1" ]]; then
    echo "[WARN] Passphrase cannot be empty. Try again."
    continue
  fi
  if [[ "$pass1" == "$pass2" ]]; then
    PASSPHRASE="$pass1"
    # Clear temporary variables
    unset pass1 pass2
    break
  else
    echo "[WARN] Passphrases do not match. Please try again."
  fi
done

echo "[INFO] Formatting ${DEVICE} with LUKS2 (PBKDF2)…"
# --pbkdf pbkdf2 forces PBKDF2 instead of Argon2.
# The dash ( - ) tells cryptsetup to read the passphrase from stdin.
printf '%s' "$PASSPHRASE" | cryptsetup luksFormat --pbkdf pbkdf2 --label ROOTFS "$DEVICE" -

echo "[INFO] Opening encrypted device as /dev/mapper/${MAPPER_NAME}…"
printf '%s' "$PASSPHRASE" | cryptsetup open "$DEVICE" "$MAPPER_NAME" -

# Clear passphrase from memory
unset PASSPHRASE

echo "[SUCCESS] ${DEVICE} is now encrypted and mapped at /dev/mapper/${MAPPER_NAME}."
