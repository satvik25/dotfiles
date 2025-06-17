#!/usr/bin/env bash
set -euo pipefail
export PS4='+ ${BASH_SOURCE:-$0}:${LINENO}: '
set -x

# Configure networking
# Note: Common troubleshooting tip: sudo ip route add default via 192.168.1.1 dev wlan0

# Enable network services
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
## Set parameters
DNSC=/etc/dnscrypt-proxy/dnscrypt-proxy.toml
LN=$(grep -n 'server_names' "$DNSC" | head -n1 | cut -d: -f1 || echo "")

## Remove existing server_names lines
if [[ -n "$LN" ]]; then
  sed -i "${LN}d" "$DNSC"
fi

## Insert our server_names line at the same line number, or before listen_addresses if none found
if [[ -n "$LN" ]]; then
  sed -i "${LN}i server_names = ['adguard-dns-doh']" "$DNSC"
else
  sed -i "/^listen_addresses/ i server_names = ['adguard-dns-doh']" "$DNSC"
fi

## Set secure DNS
sed -i 's|^#\s*require_dnssec\s*=.*|require_dnssec = true|' "$DNSC"
sed -i 's|^require_dnssec\s*=\s*false|require_dnssec = true|' "$DNSC"

set +x
echo -e "\033[32m[SUCCESS]\033[0m Network configured."
echo -e "Symlink after booting up with \033[31mln -sf /run/dnscrypt-proxy/resolv.conf /etc/resolv.conf\033[0m and restart services."
echo -e "Boot up and run the \033[31mnext [3.0] batch\033[0m of scripts."
