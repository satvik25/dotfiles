#!/usr/bin/env bash
# 1-archinstall-basics.sh - set console font and enable NTP

set -euo pipefail

setfont ter-120n
timedatectl set-ntp true
