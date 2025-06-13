#!/usr/bin/env bash
# Set console font and enable NTP
set -euo pipefail

setfont ter-120n
timedatectl set-ntp true
