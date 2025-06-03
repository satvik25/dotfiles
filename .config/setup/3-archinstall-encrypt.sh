#!/usr/bin/env bash
# 3-archinstall-encrypt.sh - encrypt root partition and open it
set -euo pipefail

# Automatically confirm formatting and let cryptsetup prompt for the passphrase
printf 'YES\n' | cryptsetup luksFormat --pbkdf pbkdf2 --label ROOTFS /dev/sda2
cryptsetup open /dev/sda2 cryptroot
