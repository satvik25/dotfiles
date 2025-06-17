#!/usr/bin/env bash
set -euo pipefail

# Post boot

curl -fsSL "https://raw.githubusercontent.com/satvik25/dotfiles/master/.config/archinstall/archinstall-3.01-pacman.sh" | bash
curl -fsSL "https://raw.githubusercontent.com/satvik25/dotfiles/master/.config/archinstall/archinstall-3.02-security.sh" | bash
curl -fsSL "https://raw.githubusercontent.com/satvik25/dotfiles/master/.config/archinstall/archinstall-3.03-dotfiles.sh" | bash
curl -fsSL "https://raw.githubusercontent.com/satvik25/dotfiles/master/.config/archinstall/archinstall-3.04-autostart.sh" | bash

echo -e "\033[32m[CONGRATULATIONS! ARCH LINUX SET UP!]\033[0m"
