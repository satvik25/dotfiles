#!/usr/bin/env bash
# ENABLE SECURE BOOT IN UEFI SETTINGS BEFORE RUNNING THIS SCRIPT!
set -euo pipefail
export PS4='+ ${BASH_SOURCE:-$0}:${LINENO}: '
set -x

# TPM setup

# Set parameters
DISK=/dev/sda
if [[ "$DISK" =~ nvme[0-9]n[0-9]$ ]]; then
  PART_ROOT="${DISK}p2"
else
  PART_ROOT="${DISK}2"
fi

# Automatic check for Secure Boot
# S1=$(
#   sbctl status \
#     | sed -r $'s/\x1b\\[[0-9;]*m//g' \
#     | grep -i '^Secure Boot:'
# )
# S2=$(printf '%s\n' "$S1" \
#   | grep -oEi 'Enabled|Disabled')
# 
# if [[ "$S2" != "Enabled" ]]; then
#   echo "Enable Secure Boot in UEFI Settings before running this script!" >&2
#   exit 1
# fi

# User warning for Secure Boot
read -r -p "Warning: Enroll TPM if Secure Boot is enabled. Continue? (Y/n) " answer < /dev/tty
answer=${answer:-Y}

case "$answer" in
    [Yy])
        ENROLL_TPM=true
        ;;
    *)
        ENROLL_TPM=false
        ;;
esac

# Enroll TPM key
set +x
if [ "$ENROLL_TPM" = true ]; then
    read -r -s -p "Enter current LUKS passphrase for ${PART_ROOT}: " L1 < /dev/tty; echo
    KEYFILE=$(mktemp)
    echo -n "$L1" > "$KEYFILE"
    chmod 400 "$KEYFILE"
    
    systemd-cryptenroll "${PART_ROOT}" \
      --unlock-key-file="$KEYFILE" \
      --tpm2-device=auto \
      --tpm2-pcrs=0+7
    
    unset "$L1"
    shred --remove "$KEYFILE"
fi
set -x

# Create crypttab initramfs
mkdir -p "$(dirname /etc/crypttab.initramfs)"
touch /etc/crypttab.initramfs
echo "cryptroot ${PART_ROOT} - tpm2-device=auto" >> /etc/crypttab.initramfs

# Define mkinitcpio hooks
HOOKS_LINE='HOOKS=(systemd autodetect microcode modconf kms block keyboard sd-vconsole sd-encrypt resume filesystems fsck)'

if grep -q '^HOOKS=' /etc/mkinitcpio.conf; then
    sed -i "/^HOOKS=/c\\${HOOKS_LINE}" /etc/mkinitcpio.conf
    echo "[*] HOOKS line updated to: ${HOOKS_LINE}"
else
    echo "WARNING: No HOOKS= line found. Appending manually."
    echo -e "\n${HOOKS_LINE}" >> /etc/mkinitcpio.conf
fi

# Generate initramfs
mkinitcpio -P

set +x
echo -e "\033[32m[SUCCESS]\033[0m TPM set."
