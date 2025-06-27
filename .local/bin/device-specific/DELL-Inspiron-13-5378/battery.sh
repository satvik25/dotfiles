#!/usr/bin/env bash
set -euo pipefail


# Install tools
yay -S --noconfirm i8kutils dell-bios-fan-control-git

# Add systemd services
# Fan control service
cat <<EOF | sudo tee /etc/systemd/system/dell-bios-fan-control.service > /dev/null
[Unit]
Description=Disable Dell BIOS fan control
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/bin/dell-bios-fan-control 0

[Install]
WantedBy=multi-user.target
EOF

## Processor service
cat <<EOF | sudo tee /etc/systemd/system/i8kmon.service > /dev/null
[Unit]
Description=Auto Fan Control using i8kmon
After=multi-user.target

[Service]
ExecStart=/usr/bin/i8kmon -d
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Enable systemd services
sudo systemctl daemon-reload
sudo systemctl enable --now dell-bios-fan-control i8kmon
