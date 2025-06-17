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

## Create firewall rules
sudo tee /usr/local/bin/update-ufw-blocklist.sh > /dev/null << 'EOF'
#!/bin/bash

# FireHOL Level 1 blocklist
BLOCKLIST_URL="https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/firehol_level1.netset"

# Temporary file to hold IPs
TMP_FILE="/tmp/firehol_blocklist.txt"

# UFW comment tag to track entries
UFW_TAG="auto-blocklist"

# Download the latest list
curl -s "$BLOCKLIST_URL" -o "$TMP_FILE" || exit 1

# Remove existing rules tagged as 'auto-blocklist'
ufw status numbered | grep "$UFW_TAG" | tac | while read -r line; do
	RULE_NUM=$(echo "$line" | awk -F'[][]' '{print $2}')
	ufw --force delete "$RULE_NUM"
done

# Add new rules
grep -vE '^\s*$|^#' "$TMP_FILE" | while read -r ip; do
    ufw deny from "$ip" comment "$UFW_TAG"
done
EOF

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

set +x
echo -e "\033[32m[SUCCESS]\033[0m Security config complete."
