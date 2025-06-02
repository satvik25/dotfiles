#!/usr/bin/env bash
# --------------------------------------------------------------------
#  Fully‑automated Arch Linux install – Btrfs + LUKS + GRUB + Secure Boot
#  ⚠  THIS SCRIPT **ERASES** EVERYTHING ON THE DRIVE SET IN $DISK  ⚠
# --------------------------------------------------------------------
set -euo pipefail

# ─────────────── USER‑TUNEABLE VARIABLES ────────────────
DISK="/dev/sda"           # Target drive
HOSTNAME="arch"           # Machine name
USERNAME="7vik"           # First user
TIMEZONE="Asia/Kolkata"   # System timezone
LOCALE="en_GB.UTF-8"       # System language (British English)
KEYMAP="us"               # Keyboard layout (US)
FONT="ter-120n"           # Console font
SWAP_SIZE="12G"           # Swapfile size
# ─────────────────────────────────────────────────────────

# ——————————————— HELPER FUNCTIONS ———————————————
msg() { printf '\e[1;32m==> %s\e[0m\n' "$*"; }
need() { command -v "$1" &>/dev/null || { echo "Required: $1"; exit 1; }; }
for cmd in sgdisk cryptsetup mkfs.fat mkfs.btrfs btrfs pacstrap genfstab arch-chroot; do need "$cmd"; done

# ——————————————— INSTALL STEPS ———————————————
partition_disk() {
  msg "Partitioning $DISK"
  sgdisk --zap-all "$DISK"
  sgdisk -n1:0:+1G -t1:ef00 -c1:BOOT "$DISK"
  sgdisk -n2:0:0   -t2:8304 -c2:ROOT "$DISK"
  partprobe "$DISK"
}

encrypt_root() {
  msg "Encrypting ROOT – you’ll be prompted for a passphrase even when the script is piped"

  # Read passphrase directly from the live TTY, independent of how the script is launched
  while true; do
      read -r -s -p "Enter new LUKS passphrase: " LUKS_PW < /dev/tty; echo
      read -r -s -p "Confirm passphrase: "         LUKS_PW2 < /dev/tty; echo
      if [[ "$LUKS_PW" == "$LUKS_PW2" && -n "$LUKS_PW" ]]; then break; fi
      echo "Passphrases didn’t match — try again." >&2
  done

  # Format and open using the passphrase from the variable, piped via stdin
  printf '%s' "$LUKS_PW" | cryptsetup luksFormat --batch-mode --pbkdf pbkdf2 --label LUKS_ROOT --key-file - "${DISK}2"
  printf '%s' "$LUKS_PW" | cryptsetup open --key-file - "${DISK}2" cryptroot
  unset LUKS_PW LUKS_PW2
}

format_fs() {
  msg "Creating filesystems"
  mkfs.fat -F32 -n BOOTFS "${DISK}1"
  mkfs.btrfs -L ROOTFS /dev/mapper/cryptroot
}

create_subvols() {
  msg "Creating Btrfs subvolumes"
  mount /dev/mapper/cryptroot /mnt
  for s in @ @home @opt @srv @cache @log @spool @tmp @swap; do
    btrfs subvolume create /mnt/$s
  done
  umount /mnt
}

mount_all() {
  msg "Mounting filesystems"
  mount -o noatime,ssd,compress=zstd,space_cache=v2,discard=async,subvol=@ /dev/mapper/cryptroot /mnt
  mkdir -p /mnt/{home,opt,srv,var/cache,var/log,var/spool,var/tmp,swap}
  for s in home opt srv; do
      mount -o noatime,ssd,compress=zstd,space_cache=v2,discard=async,subvol=@$s /dev/mapper/cryptroot /mnt/$s
  done
  for s in cache log spool tmp; do
      mount -o noatime,ssd,compress=zstd,space_cache=v2,discard=async,subvol=@$s /dev/mapper/cryptroot /mnt/var/$s
  done
  mount -o noatime,ssd,compress=no,space_cache=v2,subvol=@swap /dev/mapper/cryptroot /mnt/swap
  mount --mkdir "${DISK}1" /mnt/efi
}

make_swapfile() {
  msg "Creating $SWAP_SIZE swapfile"
  btrfs filesystem mkswapfile --size "$SWAP_SIZE" --uuid clear /mnt/swap/swapfile
  swapon /mnt/swap/swapfile
}

install_base() {
  msg "Installing base system"
  pacstrap -K /mnt \
    base linux-zen linux-lts linux-firmware intel-ucode \
    sbctl util-linux btrfs-progs grub-btrfs inotify-tools snapper \
    terminus-font sudo micro reflector zsh vlock man-db man-pages \
    brightnessctl playerctl iwd networkmanager dnscrypt-proxy \
    bluez bluez-utils cups wireless-regdb grub efibootmgr
  genfstab -U /mnt >> /mnt/etc/fstab
}

configure_chroot() {
  msg "Configuring inside chroot"
  arch-chroot /mnt /bin/bash -eu <<CHROOT
# ─── localisation ────────────────────────────
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
hwclock --systohc

echo "LANG=$LOCALE" > /etc/locale.conf
sed -i "s/^#$LOCALE UTF-8/$LOCALE UTF-8/" /etc/locale.gen
locale-gen

echo -e "KEYMAP=$KEYMAP\nFONT=$FONT" > /etc/vconsole.conf

echo "$HOSTNAME" > /etc/hostname

# ─── enable multilib ─────────────────────────
sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf
pacman -Syu --noconfirm

# ─── wireless regdom ─────────────────────────
sed -i 's/^#IN=/IN=/' /etc/conf.d/wireless-regdom

# ─── initramfs ───────────────────────────────
mkinitcpio -P

# ─── swap offsets + GRUB cmdline ─────────────
LUKS_UUID=$(blkid -s UUID -o value ${DISK}2)
ROOT_UUID=$(blkid -s UUID -o value /dev/mapper/cryptroot)
if [[ ! -f /swap/swapfile ]]; then
  echo "ERROR: /swap/swapfile not found – was swapfile creation step successful?" >&2
  exit 1
fi
SWAP_OFFSET=$(btrfs inspect-internal map-swapfile -r /swap/swapfile | awk '/physical range/ {gsub(/-/, ""); print $3}')
GRUB_LINE="cryptdevice=UUID=$LUKS_UUID:cryptroot:allow-discards root=/dev/mapper/cryptroot resume=UUID=$ROOT_UUID resume_offset=$SWAP_OFFSET zswap.enabled=1 loglevel=3 quiet"
