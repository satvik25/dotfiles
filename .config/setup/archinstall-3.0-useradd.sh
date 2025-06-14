#!/usr/bin/env bash
set -euo pipefail

# Add user(s)

# Set parameters
GROUP="wheel"
SHELL_PATH="/bin/bash"
USERNAME="7vik"

# Create user(s)
useradd -m -G "$GROUP" -s "$SHELL_PATH" "$USERNAME"

# Set user(s) password
while true; do
    read -s -p "Enter new password for $USERNAME: " P1 < /dev/tty; echo
    read -s -p "Confirm password: " P2 < /dev/tty; echo

    if [[ "$P1" == "$P2" ]]; then
        break
    else
        echo "Passwords do not match. Try again." > /dev/tty
    fi
done

passwd "$USERNAME" < <(printf "%s\n%s\n" "$P1" "$P1")

unset P1 P2

# Add user(s) to sudo
if grep -q "^# %wheel ALL=(ALL:ALL) ALL" "$/etc/sudoers"; then
  sed -i 's/^# \(%wheel ALL=(ALL:ALL) ALL\)/\1/' "$/etc/sudoers"
fi

echo -e "\033[32m[SUCCESS]\033[0m User(s) "$USERNAME" added."
