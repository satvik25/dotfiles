#!/usr/bin/env bash
# Configure security
set -euo pipefail
export PS4='+ ${BASH_SOURCE:-$0}:${LINENO}: '
set -x

sudo systemctl enable --now apparmor auditd nftables ufw

# Define mkinitcpio hooks
HOOKS_LINE='HOOKS=(systemd autodetect microcode modconf kms block keyboard sd-vconsole sd-encrypt resume filesystems fsck apparmor audit)'

if grep -q '^HOOKS=' "${MKINITCPIO_CONF}"; then
    sed -i "/^HOOKS=/c\\${HOOKS_LINE}" "${MKINITCPIO_CONF}"
    echo "[*] HOOKS line updated to: ${HOOKS_LINE}"
else
    echo "WARNING: No HOOKS= line found in ${MKINITCPIO_CONF}. Appending manually."
    echo -e "\n${HOOKS_LINE}" >> "${MKINITCPIO_CONF}"
fi

mkinitcpio -P

#Update GRUB
if grep -q '^GRUB_CMDLINE_LINUX_DEFAULT=' /etc/default/grub; then
  sudo sed -i \
    's@^\(GRUB_CMDLINE_LINUX_DEFAULT="[^"]*\)\"@\1 apparmor=1 security=apparmor"@' \
    /etc/default/grub
  echo "[*] Added apparmor=1 security=apparmor to GRUB_CMDLINE_LINUX_DEFAULT"
else
  echo '[WARN] GRUB_CMDLINE_LINUX_DEFAULT not found; appending new line'
  echo 'GRUB_CMDLINE_LINUX_DEFAULT="apparmor=1 security=apparmor"' | sudo tee -a /etc/default/grub
fi

if grep -q '^GRUB_CMDLINE_LINUX=' /etc/default/grub; then
  sudo sed -i \
    's@^\(GRUB_CMDLINE_LINUX="[^"]*\)\"@\1 lsm=landlock,lockdown,yama,integrity,apparmor,bpf"@' \
    /etc/default/grub
  echo "[*] Added lsm=landlock,lockdown,yama,integrity,apparmor,bpf to GRUB_CMDLINE_LINUX"
else
  echo '[WARN] GRUB_CMDLINE_LINUX not found; appending new line'
  echo 'GRUB_CMDLINE_LINUX="lsm=landlock,lockdown,yama,integrity,apparmor,bpf"' | sudo tee -a /etc/default/grub
fi

sudo grub-mkconfig -o /boot/grub/grub.cfg

# Firewall
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable

# Create firewall service unit
sudo tee /etc/systemd/system/ufw-blocklist.service > /dev/null << 'EOF'
[Unit]
Description=Update UFW Blocklist

[Service]
Type=oneshot
ExecStart=/usr/local/bin/update-ufw-blocklist.sh
EOF

# Create firewall timer
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

# Reload systemd and enable timer
sudo chmod +x /usr/local/bin/update-ufw-blocklist.sh
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable --now ufw-blocklist.timer
