#!/usr/bin/env bash
set -euo pipefail

curl -fsSL "https://raw.githubusercontent.com/satvik25/dotfiles/master/.config/archinstall/archinstall-3.01-useradd.sh" | bash
curl -fsSL "https://raw.githubusercontent.com/satvik25/dotfiles/master/.config/archinstall/archinstall-3.02-network.sh" | bash
curl -fsSL "https://raw.githubusercontent.com/satvik25/dotfiles/master/.config/archinstall/archinstall-3.03-pacman.sh" | bash
curl -fsSL "https://raw.githubusercontent.com/satvik25/dotfiles/master/.config/archinstall/archinstall-3.04-security.sh" | bash
curl -fsSL "https://raw.githubusercontent.com/satvik25/dotfiles/master/.config/archinstall/archinstall-3.05-dotfiles.sh" | bash
curl -fsSL "https://raw.githubusercontent.com/satvik25/dotfiles/master/.config/archinstall/archinstall-3.06-autostart.sh" | bash
