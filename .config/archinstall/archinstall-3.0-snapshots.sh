#!/usr/bin/env bash
set -euo pipefail
export PS4='+ ${BASH_SOURCE:-$0}:${LINENO}: '
set -x

# Set up snapshots

# Set up snapper
btrfs subvolume set-default "$(btrfs subvolume list -o / | awk '/ path @$/ {print $2}')" /
snapper -c root create-config /
