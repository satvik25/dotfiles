#!/usr/bin/env bash
set -euo pipefail

# Format the EFI System Partition (ESP)
mkfs.fat -F 32 -n BOOTFS /dev/sda1

# Format the decrypted LUKS container as Btrfs
mkfs.btrfs -L LUKS_ROOT /dev/mapper/cryptroot
