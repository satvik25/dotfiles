#!/usr/bin/env bash
# Reload the HID modules for the Dell Inspiron 13-5378 touch-pad
set -euo pipefail

modprobe -r hid_multitouch i2c_hid_acpi i2c_hid || true
sleep 1
modprobe i2c_hid_acpi
