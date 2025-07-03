#!/bin/bash
set -euo pipefail

# Set parameters
EXT_DIR="$HOME/.local/share/ulauncher/extensions"
mkdir -p "$EXT_DIR"

# List of extensions
EXTENSIONS=(
  "https://github.com/melianmiko/ulauncher-nmcli" 									# Network Menu
  "https://github.com/melianmiko/ulauncher-bluetoothd" 								# Bluetooth Menu
  "https://github.com/iboyperson/ulauncher-system" 									# Logout Menu
  "https://github.com/sergius02/ulauncher-colorconverter" 							# Color Converter
  "https://github.com/tchar/ulauncher-albert-calculate-anything" 					# Universal Converter
  "https://github.com/lighttigerXIV/ulauncher-terminal-runner-extension" 			# Command Runner
  "https://github.com/kbialek/ulauncher-bitwarden" 									# Passwords
  "https://github.com/Ulauncher/ulauncher-emoji" 									# Emoji
)

# Clone extensions locally
for url in "${EXTENSIONS[@]}"; do
  repo_name=$(basename "$url" .git)
  target="$EXT_DIR/$repo_name"

  if [ -d "$target" ]; then
    echo "Skipping $repo_name — already exists."
  else
    echo "Cloning $repo_name into $target..."
    git clone "$url" "$target"
  fi
done

echo "Done! Restart Ulauncher."
