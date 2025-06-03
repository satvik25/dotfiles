#!/usr/bin/env bash
# 3-archinstall-encrypt.sh - encrypt root partition and open it
set -euo pipefail

echo "Formatting /dev/sda2. You will be prompted to enter a passphrase twice." >&2
cryptsetup luksFormat --pbkdf pbkdf2 --label ROOTFS /dev/sda2

echo "Opening encrypted partition as cryptroot." >&2
cryptsetup open /dev/sda2 cryptroot
