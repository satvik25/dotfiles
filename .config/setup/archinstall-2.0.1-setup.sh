#!/usr/bin/env bash
set -euo pipefail
export PS4='+ ${BASH_SOURCE:-$0}:${LINENO}: '
set -x

sed -i '/^#\s*WIRELESS_REGDOM="IN"/ s/^#\s*//' /etc/conf.d/wireless-regdom
