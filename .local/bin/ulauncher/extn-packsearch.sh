#!/usr/bin/env bash
set -euo pipefail

# Patch Extension: PackSearch

# Set parameters
EXT_PATH="$HOME/.local/share/ulauncher/extensions/com.github.albano-a.packsearch/requirements.txt"
BACKUP="${EXT_PATH}.bak"

# Check if file exists
if [[ ! -f "$EXT_PATH" ]]; then
  echo "File $EXT_PATH does not exists." >&2
  exit 1
fi

# Make backup
cp "$EXT_PATH" "$BACKUP"
echo "Original saved as $BACKUP."

# Remove incorrect line
sed -i '/^ulauncher\.api$/d' "$EXT_PATH"

echo "[DONE] Patched extension: PackSearch."
