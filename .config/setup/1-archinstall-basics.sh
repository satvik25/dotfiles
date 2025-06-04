#!/usr/bin/env bash
# 1-setfont-ntp.sh - set console font and enable NTP
set -euo pipefail
export PS4='+ ${BASH_SOURCE:-$0}:${LINENO}: '
set -x

setfont ter-120n
timedatectl set-ntp true
