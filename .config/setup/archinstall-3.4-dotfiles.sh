#!/usr/bin/env bash
set -euo pipefail
export PS4='+ ${BASH_SOURCE:-$0}:${LINENO}: '
set -x

# Clone dotfiles repo
git clone --bare git@github.com:satvik25/dotfiles.git $HOME/.dotfiles

# Create alias
alias dots='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Checkout to home directory
dots checkout

# Curb noise
dots config --local status.showUntrackedFiles no
