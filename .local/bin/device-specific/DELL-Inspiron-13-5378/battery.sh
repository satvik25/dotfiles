#!/usr/bin/env bash
set -euo pipefail


# Control fan

# Install tool
yay -S --noconfirm i8kutils

# Add systemd service to control fan
cat <<EOF | sudo tee /etc/systemd/system/i8kmon.service > /dev/null
[Unit]
Description=Auto Fan Control using i8kmon
After=multi-user.target

[Service]
ExecStart=/usr/bin/i8kmon -t 2 -o
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Enable systemd services
sudo systemctl daemon-reload
sudo systemctl enable --now i8kmon
