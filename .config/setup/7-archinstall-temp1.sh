#!/usr/bin/env bash
set -euo pipefail
export PS4='+ ${BASH_SOURCE:-$0}:${LINENO}: '
set -x

exec arch-chroot /mnt
