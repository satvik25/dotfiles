#!/usr/bin/env bash
set -euo pipefail
export PS4='+ ${BASH_SOURCE:-$0}:${LINENO}: '
set -x

# Configure security

# Enable security services
sudo systemctl enable --now apparmor auditd nftables ufw

# Update GRUB
sed -z -E -i \
  's|(GRUB_CMDLINE_LINUX_DEFAULT="[^"]*)(")|\1 \\\napparmor=1 security=apparmor\2|' \
  /etc/default/grub

sudo bash -c 'printf "\nlsm=landlock,lockdown,yama,integrity,apparmor,bpf\n" >> /etc/default/grub'

## Generate GRUB config
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Firewall
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable

## Create firewall service unit
sudo tee /etc/systemd/system/ufw-blocklist.service > /dev/null << 'EOF'
[Unit]
Description=Update UFW Blocklist

[Service]
Type=oneshot
ExecStart=/usr/local/bin/update-ufw-blocklist.sh
EOF

## Create firewall timer
sudo tee /etc/systemd/system/ufw-blocklist.timer > /dev/null << 'EOF'
[Unit]
Description=Run UFW Blocklist Updater Daily

[Timer]
OnBootSec=5min
OnUnitActiveSec=24h
Persistent=true

[Install]
WantedBy=timers.target
EOF

## Enable firewall rules and reload
sudo chmod +x /usr/local/bin/update-ufw-blocklist.sh
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable --now ufw-blocklist.timer

echo -e "\033[32m[SUCCESS]\033[0m Security config complete."
