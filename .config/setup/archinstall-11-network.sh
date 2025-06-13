#!/usr/bin/env bash
# Configure networking 
set -euo pipefail
export PS4='+ ${BASH_SOURCE:-$0}:${LINENO}: '
set -x

systemctl enable iwd NetworkManager dnscrypt-proxy

# Configure iwd
mkdir -p /etc/iwd
touch /etc/iwd/main.conf
cat >> /etc/iwd/main.conf <<-EOF

[General]
EnableNetworkConfiguration=false
EOF

# Configure NetworkManager
cat >> /etc/NetworkManager/NetworkManager.conf <<-EOF

[main]
dns=none

[device]
wifi.backend=iwd
EOF

# Configure dnscrypt-proxy
DNSC=/etc/dnscrypt-proxy/dnscrypt-proxy.toml
LN=$(grep -n 'server_names' "$DNSC" | head -n1 | cut -d: -f1 || echo "")
# Remove existing server_names lines
if [[ -n "$LN" ]]; then
  sed -i "${LN}d" "$DNSC"
fi
# Insert our server_names line at the same line number, or before listen_addresses if none found
if [[ -n "$LN" ]]; then
  sed -i "${LN}i server_names = ['adguard-dns-doh']" "$DNSC"
else
  sed -i "/^listen_addresses/ i server_names = ['adguard-dns-doh']" "$DNSC"
fi

sed -i 's|^#\s*require_dnssec\s*=.*|require_dnssec = true|' "$DNSC"
ln -sf /run/dnscrypt-proxy/resolv.conf /etc/resolv.conf

echo -e "\033[32m[SUCCESS]\033[0m Network configured."
