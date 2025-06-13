#!/usr/bin/env bash
# 1-setfont-ntp.sh - Set console font and enable NTP
set -euo pipefail

setfont ter-120n
timedatectl set-ntp true
