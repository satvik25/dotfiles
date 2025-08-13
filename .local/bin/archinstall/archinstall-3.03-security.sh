#!/usr/bin/env bash
set -euo pipefail
export PS4='+ ${BASH_SOURCE:-$0}:${LINENO}: '
set -x

# Configure security

# Enable security services
systemctl enable --now apparmor auditd nftables ufw

# Update GRUB
sed -z -E -i \
  's|(GRUB_CMDLINE_LINUX_DEFAULT="[^"]*)(")|\1 \\\napparmor=1 security=apparmor audit=0\2|' \
  /etc/default/grub

bash -c 'printf "\nlsm=landlock,lockdown,yama,integrity,apparmor,bpf\n" >> /etc/default/grub'

## Generate GRUB config
grub-mkconfig -o /boot/grub/grub.cfg

# Firewall
ufw default deny incoming
ufw default allow outgoing
ufw enable

## Add firewall ruleset
sudo cp "/etc/nftables.conf" "/etc/nftables.conf.bak.$(date +%F_%H-%M-%S)"

sudo sed -i '/table inet filter {/a\
set blacklist4 {\
        type ipv4_addr\
        flags interval\
        auto-merge\
}\
set blacklist6 {\
        type ipv6_addr\
        flags interval\
        auto-merge\
}' /etc/nftables.conf
echo "Added blacklist ruleset."

sudo sed -i '/policy drop/a\
ip saddr @blacklist4 drop\
ip6 saddr @blacklist6 drop' /etc/nftables.conf
echo "Added blacklist drop rule."

## Create firewall service unit
tee /etc/systemd/system/user-firewall.service > /dev/null << 'EOF'
[Unit]
Description=Update nft blacklist4 from FireHOL Level 1
After=nftables.service network-online.target
Wants=nftables.service network-online.target

[Service]
Type=oneshot
ExecStart=/bin/bash -lc '%h/.local/bin/hypr-configs/user-firewall.sh'
EOF

## Create firewall timer
tee /etc/systemd/system/user-firewall.timer > /dev/null << 'EOF'
[Unit]
Description=Run FireHOL blacklist update daily at 11 PM

[Timer]
OnCalendar=*-*-* 00:00:00
RandomizedDelaySec=15m
Persistent=true

[Install]
WantedBy=timers.target
EOF

## Enable firewall rules and reload
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable --now user-firewall.timer


# Setup bw-cli
sudo ufw disable
sudo systemctl stop nftables
bw config server https://vault.bitwarden.eu
bw login satvikchaudhary@gmail.com
bw sync
sudo ufw enable
sudo systemctl start nftables


set +x
echo -e "\033[32m[SUCCESS]\033[0m Security config complete."
