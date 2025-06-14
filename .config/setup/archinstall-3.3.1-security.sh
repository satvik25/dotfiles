#!/usr/bin/env bash
set -euo pipefail
export PS4='+ ${BASH_SOURCE:-$0}:${LINENO}: '
set -x

# Configure security

# Enable security services
sudo systemctl enable --now apparmor auditd nftables ufw

# Update GRUB
sed -i \
  's|^\(GRUB_CMDLINE_LINUX_DEFAULT=".*\)"|\1 apparmor=1 security=apparmor"|' \
  /etc/default/grub
