#!/usr/bin/env bash
# 3-archinstall-encrypt.sh - encrypt root partition and open it
set -euo pipefail

# Automatically confirm formatting while still prompting for the passphrase.
printf 'YES\n' | cryptsetup luksFormat --pbkdf pbkdf2 --label ROOTFS --key-file /dev/tty /dev/sda2
cryptsetup open /dev/sda2 cryptroot
