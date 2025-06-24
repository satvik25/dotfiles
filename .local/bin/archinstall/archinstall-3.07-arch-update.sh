#!/usr/bin/env bash
set -euo pipefail

# Arch-update Weekly Timer

systemctl --user disable --now arch-update.timer

mkdir -p ~/.config/systemd/user/arch-update.timer.d
cat > ~/.config/systemd/user/arch-update.timer.d/override.conf <<EOF
[Timer]
OnCalendar=
OnCalendar=weekly
EOF

sudo systemctl daemon-reload
systemctl --user enable --now arch-update.timer
