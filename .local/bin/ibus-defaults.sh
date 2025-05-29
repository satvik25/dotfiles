# 1) Reorder the preload list
gsettings set org.freedesktop.ibus.general preload-engines "['xkb:in:eng:eng','typing-booster']"

# 2) Keep the panel/UI’s engine order in sync
gsettings set org.freedesktop.ibus.general engines-order "['xkb:in:eng:eng','typing-booster']"
