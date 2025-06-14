#!/usr/bin/env bash
set -euo pipefail
export PS4='+ ${BASH_SOURCE:-$0}:${LINENO}: '
set -x

# Configure security

# Update GRUB
sed -z -i '
  s/^\(GRUB_CMDLINE_LINUX_DEFAULT="[^"]*\)"/\1 \\
apparmor=1 security=apparmor"/
' /etc/default/grub
