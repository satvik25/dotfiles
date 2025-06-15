# Hyprland (uwsm-managed) auto-start
export PATH="$HOME/.local/bin:$PATH"

if uwsm check may-start; then
    exec uwsm start hyprland.desktop
fi
