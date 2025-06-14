#!/usr/bin/env bash
# Add user(s)
set -euo pipefail

USERNAME="7vik"
SHELL_PATH="/bin/bash"
GROUPS="wheel"
SUDOERS_FILE="/etc/sudoers"

# Create user(s)
# [FIX IT] 7vik not added to wheel group
useradd -m -G wheel -s "$SHELL_PATH" "$USERNAME"

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
if grep -q "^# %wheel ALL=(ALL:ALL) ALL" "$SUDOERS_FILE"; then
  sed -i 's/^# \(%wheel ALL=(ALL:ALL) ALL\)/\1/' "$SUDOERS_FILE"
fi

echo -e "\033[32m[SUCCESS]\033[0m User(s) "$USERNAME" added."
