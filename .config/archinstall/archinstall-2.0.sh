#!/usr/bin/env bash
set -euo pipefail

curl -fsSL "https://raw.githubusercontent.com/satvik25/dotfiles/master/.config/archinstall/archinstall-2.01-setup.sh" | bash
curl -fsSL "https://raw.githubusercontent.com/satvik25/dotfiles/master/.config/archinstall/archinstall-2.02-bootloader.sh" | bash
curl -fsSL "https://raw.githubusercontent.com/satvik25/dotfiles/master/.config/archinstall/archinstall-2.03-secureboot.sh" | bash
curl -fsSL "https://raw.githubusercontent.com/satvik25/dotfiles/master/.config/archinstall/archinstall-2.04-tpm.sh" | bash
curl -fsSL "https://raw.githubusercontent.com/satvik25/dotfiles/master/.config/archinstall/archinstall-2.05-snapshots.sh" | bash
