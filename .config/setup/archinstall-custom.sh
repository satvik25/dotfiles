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
  msg "Encrypting ROOT (you will be asked for a passphrase twice)"
  # If a LUKS header already exists (e.g. from a previous failed run) wipe it first
  if cryptsetup isLuks "${DISK}2" 2>/dev/null; then
      msg "Existing LUKS header detected on ${DISK}2 – wiping it"
      cryptsetup luksErase -f "${DISK}2"
  fi
  # --verify-passphrase guarantees a second confirmation prompt
  cryptsetup luksFormat --pbkdf pbkdf2 --verify-passphrase --label LUKS_ROOT "${DISK}2"
  # Opens with the same passphrase just provided
  cryptsetup open "${DISK}2" cryptroot
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
pacman -Sy --noconfirm

# ─── wireless regdom ─────────────────────────
sed -i 's/^#IN=/IN=/' /etc/conf.d/wireless-regdom

# ─── initramfs ───────────────────────────────
mkinitcpio -P

# ─── swap offsets + GRUB cmdline ─────────────
ROOT_UUID=$(blkid -s UUID -o value /dev/disk/by-label/ROOT)
SWAP_OFFSET=$(btrfs inspect-internal map-swapfile -r /swap/swapfile | awk '/physical range/ {gsub(/-/, ""); print $3}')
GRUB_LINE="cryptdevice=UUID=$ROOT_UUID:cryptroot:allow-discards root=/dev/mapper/cryptroot resume=UUID=$ROOT_UUID resume_offset=$SWAP_OFFSET zswap.enabled=1 loglevel=3 quiet"

sed -i "s|^GRUB_CMDLINE_LINUX_DEFAULT=.*|GRUB_CMDLINE_LINUX_DEFAULT=\"$GRUB_LINE\"|" /etc/default/grub
sed -i 's/^#GRUB_ENABLE_CRYPTODISK/GRUB_ENABLE_CRYPTODISK/' /etc/default/grub

# ─── bootloader + Secure Boot ────────────────
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB --modules="tpm" --disable-shim-lock
grub-mkconfig -o /boot/grub/grub.cfg
sbctl create-keys
sbctl enroll-keys -m
sbctl sign -s /boot/vmlinuz-linux
sbctl sign -s /efi/EFI/GRUB/grubx64.efi
mkdir -p /efi/EFI/BOOT && cp /efi/EFI/GRUB/grubx64.efi /efi/EFI/BOOT/BOOTX64.EFI

# ─── user setup ──────────────────────────────
useradd -m -G wheel -s /bin/bash $USERNAME
# Set temporary passwords (user must change on first login)
echo "root:changeme" | chpasswd
echo "$USERNAME:changeme" | chpasswd
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# ─── networking stack ────────────────────────
systemctl enable iwd NetworkManager dnscrypt-proxy
cat >/etc/iwd/main.conf <<'EOL'
[General]
EnableNetworkConfiguration=false
EOL

cat >>/etc/NetworkManager/NetworkManager.conf <<'EOL'
[main]
dns=none

[device]
wifi.backend=iwd
EOL

sed -i "s|^#server_names =.*|server_names = ['adguard-dns-doh']|" /etc/dnscrypt-proxy/dnscrypt-proxy.toml
sed -i "s/^#*require_dnssec.*/require_dnssec = true/" /etc/dnscrypt-proxy/dnscrypt-proxy.toml
ln -sf /run/dnscrypt-proxy/resolv.conf /etc/resolv.conf
systemctl restart iwd NetworkManager dnscrypt-proxy
CHROOT
}

cleanup() {
  msg "Finished – unmounting and advising reboot"
  umount -Rl /mnt || true
  swapoff -a || true
  echo -e "\e[1;33mInstallation complete. Type 'reboot' to boot into your new system.\e[0m"
}

# ——————————————— MAIN FLOW ———————————————
setfont "$FONT"
timedatectl set-ntp true
partition_disk
encrypt_root
format_fs
create_subvols
mount_all
make_swapfile
install_base
configure_chroot
cleanup
