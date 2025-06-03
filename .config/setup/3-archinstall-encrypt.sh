#!/usr/bin/env bash
# 3-archinstall-encrypt.sh - encrypt root partition and open it
set -euo pipefail

# Skip the interactive YES confirmation so the user only needs to
# provide the passphrase.
cryptsetup luksFormat --batch-mode --pbkdf pbkdf2 --label ROOTFS /dev/sda2
cryptsetup open /dev/sda2 cryptroot
