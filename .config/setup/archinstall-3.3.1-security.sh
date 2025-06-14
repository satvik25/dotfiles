#!/usr/bin/env bash
set -euo pipefail
export PS4='+ ${BASH_SOURCE:-$0}:${LINENO}: '
set -x

# Configure security

# Update GRUB
sed -z -E -i \
  's|(GRUB_CMDLINE_LINUX_DEFAULT="[^"]*)(")|\1 \\\napparmor=1 security=apparmor\2|' \
  /etc/default/grub
