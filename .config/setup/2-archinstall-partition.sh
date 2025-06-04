#!/usr/bin/env bash
# 2-archinstall-partition.sh - wipe and partition disk
set -euo pipefail
export PS4='+ ${BASH_SOURCE:-$0}:${LINENO}: '
set -x

DISK=/dev/sda

# Delete all partitions on the disk
sgdisk --zap-all "$DISK"

# Create EFI system partition
sgdisk -n1:0:+1G -t1:ef00 -c1:BOOT "$DISK"

# Create root partition using the remaining space
sgdisk -n2:0:0 -t2:8304 -c2:ROOT "$DISK"

# Inform the kernel of partition table changes
partprobe "$DISK"

echo -e "\033[32m[SUCCESS]\033[0m $DISK partitioned."
