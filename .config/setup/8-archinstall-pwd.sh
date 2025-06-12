#!/usr/bin/env bash
# 8-archinstall-pwd.sh - Password
set -euo pipefail
export PS4='+ ${BASH_SOURCE:-$0}:${LINENO}: '
set -x

# Prompt user to set root password
while true; do
    read -s -p "Enter new root password: " ROOT_PW1
    echo
    read -s -p "Confirm root password: " ROOT_PW2
    echo

    if [[ "$ROOT_PW1" == "$ROOT_PW2" ]]; then
        echo "root:$ROOT_PW1" | chpasswd
        echo "Root password set successfully."
        break
    else
        echo "Passwords do not match. Please try again."
    fi
done
