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

