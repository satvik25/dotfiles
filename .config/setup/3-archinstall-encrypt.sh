#!/usr/bin/env bash
# 3-archinstall-encrypt.sh - encrypt root partition and open it
set -euo pipefail

read -rsp "Enter passphrase for /dev/sda2: " passphrase
echo
read -rsp "Confirm passphrase: " passphrase_confirm
echo

if [[ "$passphrase" != "$passphrase_confirm" ]]; then
    echo "Error: passphrases do not match." >&2
    exit 1
fi

echo "Formatting /dev/sda2..." >&2
printf '%s' "$passphrase" | \
    cryptsetup luksFormat --pbkdf pbkdf2 --label ROOTFS --key-file - /dev/sda2

echo "Opening encrypted partition as cryptroot." >&2
printf '%s' "$passphrase" | cryptsetup open --key-file - /dev/sda2 cryptroot

unset passphrase passphrase_confirm
