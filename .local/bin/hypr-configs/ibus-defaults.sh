#!/usr/bin/env bash
set -euo pipefail

# Re-order the preload list
gsettings set org.freedesktop.ibus.general preload-engines "['xkb:in:eng:eng','typing-booster']"

# Keep the panel/UI engine order in sync
gsettings set org.freedesktop.ibus.general engines-order "['xkb:in:eng:eng','typing-booster']"
