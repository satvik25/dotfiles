#!/usr/bin/env bash

# SSID lists
SSID_DECO="AntarNet"
SSID_JIO="Source Sauce"
SSID_CORP="AntarCorporate"

# All known SSIDs
ALL_SSIDS=( "$SSID_DECO" "$SSID_JIO" "$SSID_CORP" )

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

# Ask whether to apply auto or manual settings
read -p "Configure manually or auto? (m/a): " MODE
if [[ "$MODE" == "a" ]]; then
  nmcli con mod "$CHOSEN" \
    ipv4.method auto \
	ipv4.addressess "" \
	ipv4.gateway "" \
    ipv4.dns ""
  echo "Applied auto settings to $CHOSEN."
  exit 0
fi

# If manual: ask for last octet
read -p "Enter the last octet for the IP address (1-254): " IP_SUFFIX

# Apply the correct IPv4 settings depending on SSID
if [[ "$CHOSEN" == "$SSID_DECO" ]]; then
  nmcli con mod "$CHOSEN" \
    ipv4.method manual \
    ipv4.gateway "192.168.68.1" \
    ipv4.address "192.168.68.$IP_SUFFIX" \
    ipv4.dns "127.0.0.1"
elif [[ "$CHOSEN" == "$SSID_JIO" ]]; then
  nmcli con mod "$CHOSEN" \
    ipv4.method manual \
    ipv4.gateway "192.168.31.1" \
    ipv4.address "192.168.31.$IP_SUFFIX" \
    ipv4.dns "127.0.0.1"
elif [[ "$CHOSEN" == "$SSID_CORP" ]]; then
  nmcli con mod "$CHOSEN" \
    ipv4.method manual \
    ipv4.gateway "192.168.1.1" \
    ipv4.address "192.168.1.$IP_SUFFIX" \
    ipv4.dns "127.0.0.1"
fi

# Restart network services and bring connection back up
# nmcli con down "$CHOSEN"
sudo systemctl restart iwd NetworkManager dnscrypt-proxy    # % rs-network
nmcli con up "$CHOSEN"

# Connectivity test
ping -c 3 1.1.1.1
ping -c 3 archlinux.org
