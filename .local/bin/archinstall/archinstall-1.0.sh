#!/usr/bin/env bash
set -euo pipefail

# Pre chroot
# Connect to the internet: iwctl station wlan0
## Troubleshooting tip: Might need to run the following:
## dhcpcd wlan0
## ip route add default via 192.168.1.1 dev wlan0
# Run the scripts: curl -fsSL "https://raw.githubusercontent.com/satvik25/dotfiles/master/.config/archinstall/archinstall-1.0.sh" | bash

curl -fsSL "https://raw.githubusercontent.com/satvik25/dotfiles/master/.local/bin/archinstall/archinstall-1.01-basics.sh" | bash
curl -fsSL "https://raw.githubusercontent.com/satvik25/dotfiles/master/.local/bin/archinstall/archinstall-1.02-partition.sh" | bash
curl -fsSL "https://raw.githubusercontent.com/satvik25/dotfiles/master/.local/bin/archinstall/archinstall-1.03-encrypt.sh" | bash
curl -fsSL "https://raw.githubusercontent.com/satvik25/dotfiles/master/.local/bin/archinstall/archinstall-1.04-format.sh" | bash
curl -fsSL "https://raw.githubusercontent.com/satvik25/dotfiles/master/.local/bin/archinstall/archinstall-1.05-mount.sh" | bash
curl -fsSL "https://raw.githubusercontent.com/satvik25/dotfiles/master/.local/bin/archinstall/archinstall-1.06-install.sh" | bash

echo -e "Chroot manually with \033[31march-chroot /mnt.\033[0m"
