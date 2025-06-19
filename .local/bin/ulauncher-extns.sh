#!/bin/bash

# Set parameters
EXT_DIR="$HOME/.local/share/ulauncher/extensions"
mkdir -p "$EXT_DIR"

# List of extensions
EXTENSIONS=(
  "https://github.com/melianmiko/ulauncher-nmcli"
  "https://github.com/melianmiko/ulauncher-bluetoothd"
  "https://github.com/iboyperson/ulauncher-system"
  "https://github.com/sergius02/ulauncher-colorconverter"
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
