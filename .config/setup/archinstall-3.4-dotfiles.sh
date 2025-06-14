#!/usr/bin/env bash
set -euo pipefail

# Clone dotfiles repo
git clone --bare https://github.com/satvik25/dotfiles.git $HOME/.dotfiles

# Create alias
alias dots='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
echo "alias dots='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'" >> $HOME/.zshrc

# Checkout to home directory
dots checkout

# Curb noise
dots config --local status.showUntrackedFiles no
