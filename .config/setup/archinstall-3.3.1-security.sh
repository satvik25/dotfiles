#!/usr/bin/env bash
set -euo pipefail
export PS4='+ ${BASH_SOURCE:-$0}:${LINENO}: '
set -x

# Configure security

# Update GRUB
sudo bash -c 'printf "\nlsm=landlock,lockdown,yama,integrity,apparmor,bpf\n" >> /etc/default/grub'
