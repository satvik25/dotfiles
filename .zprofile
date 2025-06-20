# Local files prioritised over system files
export PATH="$HOME/.local/bin:$PATH"

# Store ssh passphrase once for session
if ! pgrep -u "$USER" ssh-agent >/dev/null; then
  eval "$(ssh-agent -s)"
  ssh-add
fi

# Hyprland (uwsm-managed) autostart
# if uwsm check may-start; then
#     exec uwsm start hyprland.desktop
# fi
