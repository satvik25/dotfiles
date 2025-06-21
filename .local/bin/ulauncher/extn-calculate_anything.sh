#!/usr/bin/env bash
set -euo pipefail

# Extension Patch: Calculate Anything

# Set parameters
EXT_PATH="$HOME/.local/share/ulauncher/extensions/com.github.tchar.ulauncher-albert-calculate-anything/main.py"
BACKUP="${EXT_PATH}.bak"

# Check if file exists
if [[ ! -f "$EXT_PATH" ]]; then
  echo "File $EXT_PATH does not exists." >&2
  exit 1
fi

# Make backup
cp "$EXT_PATH" "$BACKUP"
echo "Original saved as $BACKUP."

# Replace incorrect line
sed -i "/^[[:space:]]*query = query\.replace(event\.get_keyword() + ' ', '', 1)/c\        query = event.get_argument()" "$EXT_PATH"
# If get_argument() method does not work, replace rogue line [line 56] with these lines:
# full = event.get_query()
# kw   = event.get_keyword() + ' '
# query = full[len(kw):] if full.startswith(kw) else full

echo "[DONE] Patched extension: Calculate Anything."
