#!/usr/bin/env bash
# Configure networking 
set -euo pipefail
export PS4='+ ${BASH_SOURCE:-$0}:${LINENO}: '
set -x

systemctl enable iwd NetworkManager dnscrypt-proxy

# Configure iwd
cat >> /etc/iwd/main.conf <<-EOF

[General]
EnableNetworkConfiguration=false
EOF

# Configure NetworkManager
