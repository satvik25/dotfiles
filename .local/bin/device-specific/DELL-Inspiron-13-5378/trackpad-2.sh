#!/bin/sh
# Reload the I²C-HID stack to clear the stuck-gesture state
/usr/bin/modprobe -r hid_multitouch i2c_hid_acpi i2c_hid
/usr/bin/modprobe    i2c_hid_acpi
