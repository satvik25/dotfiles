#!/usr/bin/env bash

# SSID lists
SSID_N=( "AntarNet" "AntarCorporate" )
SSID_JIO="Source Sauce"

# All known SSIDs
ALL_SSIDS=( "${SSID_N[@]}" "$SSID_JIO" )

# Prompt user
echo "Select which network you want to fix:"
PS3="Enter number: "
select CHOSEN in "${ALL_SSIDS[@]}"; do
  if [[ -n "$CHOSEN" ]]; then
    echo "You chose: $CHOSEN"
    break
  else
    echo "Invalid choice. Try again."
  fi
done

# Apply the correct IPv4 settings depending on whether it's a Jio or normal SSID
if [[ "$CHOSEN" == "$SSID_JIO" ]]; then
  # JIO network settings
  nmcli con mod "$CHOSEN" \
    ipv4.gateway "192.168.31.1" \
    ipv4.address "192.168.31.252" \
    ipv4.dns "127.0.0.1" \
    ipv4.method manual
else
  # Normal networks share the same settings
  nmcli con mod "$CHOSEN" \
    ipv4.gateway "192.168.1.1" \
    ipv4.address "192.168.1.252" \
    ipv4.dns "127.0.0.1" \
    ipv4.method manual
fi

# Bring it down, restart services, bring it back up
nmcli con down "$CHOSEN"
sudo systemctl restart iwd NetworkManager dnscrypt-proxy		# % rs-network
nmcli con up "$CHOSEN"

# Connectivity test
ping -c 3 1.1.1.1
ping -c 3 archlinux.org
