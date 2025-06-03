#!/usr/bin/env bash
# 3-archinstall-encrypt.sh - encrypt root partition and open it
set -euo pipefail

while true; do
    read -rsp "Enter passphrase for /dev/sda2: " passphrase
    echo
    read -rsp "Confirm passphrase: " passphrase_confirm
    echo

    if [[ "$passphrase" == "$passphrase_confirm" ]]; then
        break
    fi

    echo "Passphrases do not match. Please try again." >&2
done

echo "Formatting /dev/sda2..." >&2
printf '%s' "$passphrase" | \
    cryptsetup luksFormat --pbkdf pbkdf2 --label ROOTFS --key-file - /dev/sda2

echo "Opening encrypted partition as cryptroot." >&2
printf '%s' "$passphrase" | cryptsetup open --key-file - /dev/sda2 cryptroot

unset passphrase passphrase_confirm
