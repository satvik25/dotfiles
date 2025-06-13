#!/usr/bin/env bash
# TPM setup
# ENABLE SECURE BOOT IN UEFI SETTINGS BEFORE RUNNING THIS SCRIPT!
set -euo pipefail
export PS4='+ ${BASH_SOURCE:-$0}:${LINENO}: '
set -x

PART_ROOT="/dev/sda2"
CRYPTTAB_INIT_RAMFS="/etc/crypttab.initramfs"
MKINITCPIO_CONF="/etc/mkinitcpio.conf"

# Enroll TPM key
read -r -s -p "Enter current LUKS passphrase for ${PART_ROOT}: " PASS1 < /dev/tty; echo
KEYFILE=$(mktemp)
echo -n "$PASS1" > "$KEYFILE"
chmod 400 "$KEYFILE"

systemd-cryptenroll "${PART_ROOT}" \
  --unlock-key-file="$KEYFILE" \
  --tpm2-device=auto \
  --tpm2-pcrs=0+7

unset "$PASS1"
shred --remove "$KEYFILE"

# Create crypttab initramfs
mkdir -p "$(dirname \"${CRYPTTAB_INIT_RAMFS}\")"
touch "${CRYPTTAB_INIT_RAMFS}"
echo "cryptroot ${PART_ROOT} - tpm2-device=auto" >> "${CRYPTTAB_INIT_RAMFS}"

# Define mkinitcpio hooks
HOOKS_LINE='HOOKS=(systemd autodetect microcode modconf kms block keyboard sd-vconsole sd-encrypt resume filesystems fsck)'

if grep -q '^HOOKS=' "${MKINITCPIO_CONF}"; then
    sed -i "/^HOOKS=/c\\${HOOKS_LINE}" "${MKINITCPIO_CONF}"
    echo "[*] HOOKS line updated to: ${HOOKS_LINE}"
else
    echo "WARNING: No HOOKS= line found in ${MKINITCPIO_CONF}. Appending manually."
    echo -e "\n${HOOKS_LINE}" >> "${MKINITCPIO_CONF}"
fi

mkinitcpio -P

echo -e "\033[32m[SUCCESS]\033[0m TPM setup."
