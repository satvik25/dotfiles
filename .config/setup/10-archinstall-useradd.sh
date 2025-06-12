#!/usr/bin/env bash
# 10-archinstall-useradd.sh - Add User
set -euo pipefail
export PS4='+ ${BASH_SOURCE:-$0}:${LINENO}: '
set -x

# Configuration
USERNAME="7vik"
SHELL_PATH="/bin/bash"
GROUPS="wheel"
SUDOERS_FILE="/etc/sudoers"

# Create the user with home directory, wheel group, and specified shell
  useradd -m -G "$GROUPS" -s "$SHELL_PATH" "$USERNAME"
  echo "User '$USERNAME' created and added to groups: $GROUPS."

# Read password securely from terminal
while true; do
    read -s -p "Enter new password for $USERNAME: " P1 < /dev/tty; echo
    read -s -p "Confirm password: " P2 < /dev/tty; echo

    if [[ "$P1" == "$P2" ]]; then
        break
    else
        echo "Passwords do not match. Try again." > /dev/tty
    fi
done

# Feed passwords to passwd via /dev/tty-compatible input
passwd "$USERNAME" < <(printf "%s\n%s\n" "$P1" "$P1")
  
# Uncomment the sudoers line for wheel group
if grep -q "^# %wheel ALL=(ALL:ALL) ALL" "$SUDOERS_FILE"; then
  sed -i 's/^# \(%wheel ALL=(ALL:ALL) ALL\)/\1/' "$SUDOERS_FILE"
 
# Done
echo "User setup complete."
