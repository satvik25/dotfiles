#!/usr/bin/env bash
set -euo pipefail

# Post boot

# Prompt for profile / dotfiles
while true; do
    echo -e "\033[35m[Choose]\033[0m"
    echo -e "\033[35m[A]\033[0m Configure system profile"
    echo -e "\033[35m[B]\033[0m Restore dotfiles"
    read -r -p "A or B? " answer < /dev/tty

    case "$answer" in
        [Aa])
            curl -fsSL "https://raw.githubusercontent.com/satvik25/dotfiles/master/.local/bin/archinstall/archinstall-3.01-snapshots.sh" | sudo bash
            curl -fsSL "https://raw.githubusercontent.com/satvik25/dotfiles/master/.local/bin/archinstall/archinstall-3.02-pacman.sh" | bash
            curl -fsSL "https://raw.githubusercontent.com/satvik25/dotfiles/master/.local/bin/archinstall/archinstall-3.03-security.sh" | sudo bash

            echo -e "\033[32m[SUCCESS]\033[0m System profile set up."
            break
            ;;
        [Bb])
            curl -fsSL "https://raw.githubusercontent.com/satvik25/dotfiles/master/.local/bin/archinstall/archinstall-3.04-dotfiles.sh" | bash
            curl -fsSL "https://raw.githubusercontent.com/satvik25/dotfiles/master/.local/bin/archinstall/archinstall-3.05-autostart.sh" | bash
            curl -fsSL "https://raw.githubusercontent.com/satvik25/dotfiles/master/.local/bin/archinstall/archinstall-3.06-theming.sh" | bash
            curl -fsSL "https://raw.githubusercontent.com/satvik25/dotfiles/master/.local/bin/archinstall/archinstall-3.07-arch-update.sh" | bash
            echo -e "\033[32m[CONGRATULATIONS!]\033[0m \033[34mArch set up.\033[0m"
            break
            ;;
        *)
            echo -e "\033[31m[Incorrect Input]\033[0m Choose either A or B."
            ;;
    esac
done
