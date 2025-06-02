#!/usr/bin/env bash
set -euo pipefail

DISK="/dev/sda"
HOSTNAME="arch"
USERNAME="7vik"
TIMEZONE="Asia/Kolkata"
LOCALE="en_GB.UTF-8"
KEYMAP="us"
FONT="ter-120n"
SWAP_SIZE="12G"

need() { command -v "$1" &>/dev/null || { echo "Required: $1"; exit 1; }; }
for c in sgdisk cryptsetup mkfs.fat mkfs.btrfs btrfs pacstrap genfstab arch-chroot; do need "$c"; done
msg() { printf '\e[1;32m==> %s\e[0m\n' "$*"; }

partition_disk() {
  msg "Partitioning $DISK"
  sgdisk --zap-all "$DISK"
  sgdisk -n1:0:+1G -t1:ef00 -c1:BOOT "$DISK"
  sgdisk -n2:0:0   -t2:8304 -c2:ROOT "$DISK"
  partprobe "$DISK"
}

encrypt_root() {
  msg "Encrypting ROOT"
  while true; do
    read -r -s -p "Enter new LUKS passphrase: " L1 < /dev/tty; echo
    read -r -s -p "Confirm passphrase: "         L2 < /dev/tty; echo
    [[ "$L1" == "$L2" && -n "$L1" ]] && break
    echo "Passphrases didn’t match" >&2
  done
  printf '%s' "$L1" | cryptsetup luksFormat --batch-mode --pbkdf pbkdf2 --label LUKS_ROOT --key-file - "${DISK}2"
  printf '%s' "$L1" | cryptsetup open --key-file - "${DISK}2" cryptroot
  unset L1 L2
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
  msg "Mounting subvolumes"
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
  msg "Creating swapfile"
  [[ -f /mnt/swap/swapfile ]] || btrfs filesystem mkswapfile --size "$SWAP_SIZE" --uuid clear /mnt/swap/swapfile
  swapon /mnt/swap/swapfile || true
}

install_base() {
  msg "Installing base system"
  pacstrap -K /mnt base linux-zen linux-lts linux-firmware intel-ucode \
    sbctl util-linux btrfs-progs grub-btrfs inotify-tools snapper \
    terminus-font sudo micro reflector zsh vlock man-db man-pages \
    brightnessctl playerctl iwd networkmanager dnscrypt-proxy \
    bluez bluez-utils cups wireless-regdb grub efibootmgr
  genfstab -U /mnt >> /mnt/etc/fstab
}

configure_chroot() {
  msg "Configuring base system inside chroot"
  arch-chroot /mnt /bin/bash -eu <<'CHROOT'
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc
echo "LANG=en_GB.UTF-8" > /etc/locale.conf
sed -i "s/^# *en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/" /etc/locale.gen
locale-gen
echo -e "KEYMAP=us\nFONT=ter-120n" > /etc/vconsole.conf
echo "arch" > /etc/hostname
sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf
pacman -Sy --noconfirm
sed -i 's/^#IN=/IN=/' /etc/conf.d/wireless-regdom
mkinitcpio -P
CHROOT
}

configure_bootloader() {
  msg "Setting up GRUB"
  arch-chroot /mnt /bin/bash -eu <<'CHROOT'
LUKS_UUID=$(blkid -s UUID -o value /dev/disk/by-label/ROOT)
SWAP_OFFSET=$(btrfs inspect-internal map-swapfile -r /swap/swapfile | awk '/physical range/ {gsub(/-/, ""); print $3}')
sed -i "s|^GRUB_CMDLINE_LINUX_DEFAULT=.*|GRUB_CMDLINE_LINUX_DEFAULT=\"cryptdevice=UUID=${LUKS_UUID}:cryptroot:allow-discards root=/dev/mapper/cryptroot resume=UUID=${LUKS_UUID} resume_offset=${SWAP_OFFSET} zswap.enabled=1 loglevel=3 quiet\"|" /etc/default/grub
sed -i 's/^#GRUB_ENABLE_CRYPTODISK/GRUB_ENABLE_CRYPTODISK/' /etc/default/grub
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB --modules="tpm" --disable-shim-lock
grub-mkconfig -o /boot/grub/grub.cfg
mkdir -p /efi/EFI/BOOT && cp /efi/EFI/GRUB/grubx64.efi /efi/EFI/BOOT/BOOTX64.EFI
CHROOT
}

add_user() {
  msg "Adding user $USERNAME"
  arch-chroot /mnt /bin/bash -eu <<CHROOT
useradd -m -G wheel -s /bin/bash $USERNAME
passwd $USERNAME
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
CHROOT
}

configure_network() {
  msg "Configuring networking"
  arch-chroot /mnt /bin/bash -eu <<'CHROOT'
systemctl enable iwd NetworkManager dnscrypt-proxy
mkdir -p /etc/iwd
printf "[General]\nEnableNetworkConfiguration=false\n" > /etc/iwd/main.conf
mkdir -p /etc/NetworkManager
cat >/etc/NetworkManager/NetworkManager.conf <<'EOF'
[main]
dns=none

[device]
wifi.backend=iwd
EOF
sed -i "s|^#*require_dnssec.*|require_dnssec = true|" /etc/dnscrypt-proxy/dnscrypt-proxy.toml
if ! grep -q "server_names = \['adguard-dns-doh'" /etc/dnscrypt-proxy/dnscrypt-proxy.toml; then
  sed -i "/^#.*server_names *=/a server_names = ['adguard-dns-doh']" /etc/dnscrypt-proxy/dnscrypt-proxy.toml
fi
ln -sf /run/dnscrypt-proxy/resolv.conf /etc/resolv.conf
CHROOT
}

main() {
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
  configure_bootloader
  add_user
  configure_network
  umount -Rl /mnt
  swapoff -a || true
  msg "Done – reboot when ready"
}

main
