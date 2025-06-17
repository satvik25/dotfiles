#!/usr/bin/env bash
set -euo pipefail

# Post boot

# Prompt for profile / dotfiles
echo -e "\033[35m[Choose]\033[0m"
echo -e "\033[35m[A]\033[0m Configure system profile"
echo -e "\033[35m[B]\033[0m Restore dotfiles"
read -r -p "A or B?" answer < /dev/tty
case "$answer" in
    [Aa])
        curl -fsSL "https://raw.githubusercontent.com/satvik25/dotfiles/master/.config/archinstall/archinstall-3.01-snapshots.sh" | sudo bash
        curl -fsSL "https://raw.githubusercontent.com/satvik25/dotfiles/master/.config/archinstall/archinstall-3.02-pacman.sh" | bash
        curl -fsSL "https://raw.githubusercontent.com/satvik25/dotfiles/master/.config/archinstall/archinstall-3.03-security.sh" | sudo bash

        echo -e "\033[32m[SUCCESS]\033[0m System profile set up."
        ;;
    [Bb])
        curl -fsSL "https://raw.githubusercontent.com/satvik25/dotfiles/master/.config/archinstall/archinstall-3.04-dotfiles.sh" | bash
        curl -fsSL "https://raw.githubusercontent.com/satvik25/dotfiles/master/.config/archinstall/archinstall-3.05-autostart.sh" | bash

        echo -e "\033[32m[CONGRATULATIONS!]\033[0m \033[34mArch set up.\033[0m"
        ;;
    *)
        echo "Choose A or B."
        exit 1
        ;;
esac
