#!/usr/bin/env bash
set -euo pipefail

# Check for pre-existing dotfiles directory
if [[ -d "$HOME/.dotfiles" ]]; then
  read -rp "$HOME/.dotfiles already exists. Delete it? [y/N] " answer
  case "$answer" in
    [yY])  rm -rf "$HOME/.dotfiles" ;;
    *)     echo "Aborting."; exit 1 ;;
  esac
fi

# Clone dotfiles repo
git clone --bare https://github.com/satvik25/dotfiles.git $HOME/.dotfiles

# Create alias
alias dots='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Checkout to home directory
dots checkout --force

# Curb noise
dots config --local status.showUntrackedFiles no

# Update zshrc
source ~/.zshrc
