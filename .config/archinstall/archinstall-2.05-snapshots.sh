#!/usr/bin/env bash
set -euo pipefail
export PS4='+ ${BASH_SOURCE:-$0}:${LINENO}: '
set -x

# Set up snapshots

# Create snapper root config
cat <<EOF > /etc/snapper/configs/root
SUBVOLUME="/"
ALLOW_USERS="root"
TIMELINE_CREATE="no"
TIMELINE_CLEANUP="yes"
TIMELINE_LIMIT_HOURLY="24"
TIMELINE_LIMIT_DAILY="7"
TIMELINE_LIMIT_WEEKLY="0"
TIMELINE_LIMIT_MONTHLY="0"
TIMELINE_LIMIT_YEARLY="0"
NUMBER_CLEANUP="yes"
NUMBER_LIMIT="50"
NUMBER_LIMIT_IMPORTANT="10"
EOF

# Set @ as default subvolume
btrfs subvolume set-default "$(btrfs subvolume list / | awk '{if ($(NF) == "@") print $2}')" /

# Enable GRUB snapshots menu and generate config
systemctl enable grub-btrfsd.service
grub-mkconfig -o /boot/grub/grub.cfg

set +x
echo -e "\033[32m[SUCCESS]\033[0m Added snapshot capability."
