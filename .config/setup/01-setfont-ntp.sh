#!/usr/bin/env bash
# 01-setfont-ntp.sh - set console font and enable NTP

set -euo pipefail

setfont ter-120n
timedatectl set-ntp true
