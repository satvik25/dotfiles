#!/usr/bin/env bash
# 8-archinstall-pwd.sh - Password
set -euo pipefail
export PS4='+ ${BASH_SOURCE:-$0}:${LINENO}: '
set -x

# Read password securely from terminal
while true; do
    read -s -p "Enter new root password: " ROOT1 < /dev/tty; echo
    read -s -p "Confirm root password: " ROOT2 < /dev/tty; echo

    if [[ "$ROOT1" == "$ROOT2" ]]; then
        break
    else
        echo "Passwords do not match. Try again." > /dev/tty
    fi
done

# Set password
passwd root < <(printf "%s\n%s\n" "$ROOT1" "$ROOT1")
