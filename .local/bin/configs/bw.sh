#! /usr/bin/env bash
set -euo pipefail

# Setup bw cli

sudo ufw disable
sudo systemctl stop nftables
bw config server https://vault.bitwarden.eu
bw login satvikchaudhary@gmail.com
bw sync
sudo ufw enable
sudo systemctl start nftables
