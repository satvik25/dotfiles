#!/usr/bin/env bash
#
# install-i2c-hid-fix.sh ─ Disable runtime-PM for all HID-over-I²C bridges
#                          (prevents Dell “infinite-zoom” touch-gesture bug)
#
# ▸ Creates /etc/udev/rules.d/99-i2c-hid-runtimepm.rules
# ▸ Reloads udev rules
# ▸ Re-loads i2c_hid drivers so the rule is applied immediately
#
# Re-run safely at any time; if the rule already exists it is left untouched.

set -euo pipefail

RULE_FILE="/etc/udev/rules.d/99-i2c-hid-runtimepm.rules"
RULE_TEXT='ACTION=="bind", SUBSYSTEM=="i2c", DRIVERS=="i2c_hid*|i2c_hid_acpi*", \
  TEST=="power/control", ATTR{power/control}="on"'

install_rule() {
  echo "► Installing udev rule …"
  printf '%s\n# Disable runtime-PM for all I²C-HID bridges\n%s\n' \
         "$(date '+# Added %F %T')" "${RULE_TEXT}" \
         | sudo tee "${RULE_FILE}" > /dev/null
}

reload_udev() {
  echo "► Reloading udev rules …"
  sudo udevadm control --reload-rules
}

rebind_driver() {
  echo "► Rebinding i2c_hid driver to apply rule immediately …"
  sudo modprobe -r hid_multitouch i2c_hid_acpi i2c_hid || true
  sudo modprobe    i2c_hid_acpi
}

# ────────────────────────────────────────────────────────────────────────────
if [[ $EUID -ne 0 ]]; then
  echo "Please run as root (sudo $0)"
  exit 1
fi

if [[ -f ${RULE_FILE} && $(grep -F "${RULE_TEXT}" "${RULE_FILE}" || true) ]]; then
  echo "Rule already present – skipping write."
else
  install_rule
fi

reload_udev
rebind_driver
echo "✔  I²C-HID runtime-PM disabled.  You’re all set!"
