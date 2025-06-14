#!/usr/bin/env bash
set -euo pipefail
export PS4='+ ${BASH_SOURCE:-$0}:${LINENO}: '
set -x

# Clone dotfiles repo
git clone --bare git@github.com:satvik25/dotfiles.git $HOME/.dotfiles

# Create alias
echo "alias dots='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'" >> $HOME/.zshrc

# Checkout to home directory
dots checkout

# Curb noise
dots config --local status.showUntrackedFiles no
