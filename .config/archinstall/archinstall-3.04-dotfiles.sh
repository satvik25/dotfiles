#!/usr/bin/env bash
set -euo pipefail

# SSH authentication
# ssh-keygen -t ed25519 -C "your-email@example.com"
# eval "$(ssh-agent -s)"
# ssh-add ~/.ssh/id_ed25519
# ssh-add -l
# Paste output of cat ~/.ssh/id_ed25519.pub to GitHub ▸ Settings ▸ SSH and GPG keys ▸ New SSH key → paste → Add key.
# ssh -T git@github.com

# Usage
# Set remote with dots config --global push.autoSetupRemote true.
# Update tracked files with dots add -u or Add new files to track with dots add <xyz>.
# dots commit -m "VERSION_NAME"
# dots push
# Update local dotfiles with dots pull --rebase origin master and then dots push if newer changes made to repo from another machine.

export PS4='+ ${BASH_SOURCE:-$0}:${LINENO}: '
set -x

# Set parameters
GIT_USERNAME="satvik25"

# Set author identity
git config --global user.email satvikchaudhary@gmail.com
git congfig --global user.name 7vik

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

set +x
echo -e "\033[32m[SUCCESS]\033[0m Dotfiles restored."
set -x

# Update shell
exec zsh
