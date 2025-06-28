#!/usr/bin/env bash
set -euo pipefail

# Give the kernel a clean slate
modprobe -r hid_multitouch i2c_hid_acpi i2c_hid || true
sleep 0.5               # brief pause so the bus settles
modprobe    i2c_hid_acpi
logger -t reset-touchpad "Touch-pad modules reloaded"
