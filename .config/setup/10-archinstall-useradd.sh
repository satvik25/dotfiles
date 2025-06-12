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
  
# Uncomment the sudoers line for wheel group
if grep -q "^# %wheel ALL=(ALL:ALL) ALL" "$SUDOERS_FILE"; then
  sed -i 's/^# \(%wheel ALL=(ALL:ALL) ALL\)/\1/' "$SUDOERS_FILE"
  echo "Uncommented '%wheel ALL=(ALL:ALL) ALL' in $SUDOERS_FILE."
else
  echo "No commented wheel sudoers line found or already enabled."
fi

# Verify sudoers syntax
if visudo -c; then
  echo "sudoers file syntax is OK."
else
  echo "Error in sudoers file syntax! Please review $SUDOERS_FILE." >&2
  exit 1
fi

# Done
echo "User setup complete."
