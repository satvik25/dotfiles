#!/usr/bin/env bash
set -euo pipefail

# Set parameters
GIT_USERNAME="?"

# Check for pre-existing dotfiles directory
if [[ -d "$HOME/.dotfiles" ]]; then
  read -rp "$HOME/.dotfiles already exists. Delete it? [y/N] " answer < /dev/tty
  case "$answer" in
    [yY])  rm -rf "$HOME/.dotfiles" ;;
    *)     echo "Aborting."; exit 1 ;;
  esac
fi

# Clone dotfiles repo
git clone --bare git@github.com:"$GIT_USERNAME"/dotfiles.git $HOME/.dotfiles

# Create alias
dots() { 
  /usr/bin/git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME" "$@"
}

# Checkout to home directory
dots checkout --force

# Curb noise
dots config --local status.showUntrackedFiles no

echo -e "\033[32m[SUCCESS]\033[0m Dotfiles restored."

# Update shell
exec zsh

# SSH authentication
# ssh-keygen -t ed25519 -C "your-email@example.com"
# eval "$(ssh-agent -s)"
# ssh-add ~/.ssh/id_ed25519
# ssh-add -l
# Paste output of cat ~/.ssh/id_ed25519.pub to GitHub ▸ Settings ▸ SSH and GPG keys ▸ New SSH key → paste → Add key.
# ssh -T git@github.com

# Usage
# Set remote with dots config --global push.autoSetupRemote true
# Update tracked files with dots add -u or Add new files to track with dots add <xyz>
# dots commit -m "VERSION_NAME"
# dots push
