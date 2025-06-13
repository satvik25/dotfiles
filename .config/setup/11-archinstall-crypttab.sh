#!/usr/bin/env bash
# 11-archinstall-crypttab.sh – Crypttab
set -euo pipefail
export PS4='+ ${BASH_SOURCE:-$0}:${LINENO}: '
set -x

# Variables - adjust as needed
PART_ROOT="/dev/sda2"
CRYPTTAB_INIT_RAMFS="/etc/crypttab.initramfs"
MKINITCPIO_CONF="/etc/mkinitcpio.conf"

# Enter Password
read -r -s -p "Enter current LUKS passphrase for ${PART_ROOT}: " PASS1 < /dev/tty; echo
KEYFILE=$(mktemp)
echo -n "$PASS1" > "$KEYFILE"
chmod 400 "$KEYFILE"

# 1. Enroll LUKS key slot into TPM2
echo "[*] Enrolling LUKS key for ${PART_ROOT} into TPM2..."
systemd-cryptenroll "${PART_ROOT}" \
  --unlock-key-file="$KEYFILE" \
  --tpm2-device=auto \
  --tpm2-pcrs=0+7

echo "[*] LUKS key enrolled successfully."

unset "$PASS1"
shred --remove "$KEYFILE"

# 2. Register encrypted root in initramfs crypttab
echo "[*] Adding entry to ${CRYPTTAB_INIT_RAMFS}..."
# Ensure the file exists
mkdir -p "$(dirname \"${CRYPTTAB_INIT_RAMFS}\")"
touch "${CRYPTTAB_INIT_RAMFS}"
echo "cryptroot ${PART_ROOT} - tpm2-device=auto" >> "${CRYPTTAB_INIT_RAMFS}"
echo "[*] Entry added to ${CRYPTTAB_INIT_RAMFS}."

# 3. Update mkinitcpio HOOKS line
echo "[*] Updating HOOKS in ${MKINITCPIO_CONF}..."

# Define desired hooks
HOOKS_LINE='HOOKS=(systemd autodetect microcode modconf kms block keyboard sd-vconsole sd-encrypt resume filesystems fsck)'

# Use sed to replace the existing HOOKS line
if grep -q '^HOOKS=' "${MKINITCPIO_CONF}"; then
    sed -i "/^HOOKS=/c\\${HOOKS_LINE}" "${MKINITCPIO_CONF}"
    echo "[*] HOOKS line updated to: ${HOOKS_LINE}"
else
    echo "WARNING: No HOOKS= line found in ${MKINITCPIO_CONF}. Appending manually."
    echo -e "\n${HOOKS_LINE}" >> "${MKINITCPIO_CONF}"
fi

# 4. Regenerate initramfs images
echo "[*] Regenerating initramfs..."
mkinitcpio -P

echo "[*] initramfs rebuilt successfully."

echo "[+] All steps completed. You can now proceed with installing the rest of the system packages using pacstrap, configuration, and bootloader setup."
