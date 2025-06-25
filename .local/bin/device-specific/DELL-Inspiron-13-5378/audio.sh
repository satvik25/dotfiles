#!/usr/bin/env bash
#
# audio.sh — disable HDA power-save & install a udev rule
# to pin IRQ 130 across CPUs 0–3 on a Dell Inspiron 13 5378
#

set -euo pipefail

# 1. Disable HDA power-save
MODPROBE_CONF='/etc/modprobe.d/audio_powersave.conf'
echo "Writing $MODPROBE_CONF…"
sudo tee "$MODPROBE_CONF" > /dev/null <<EOF
options snd_hda_intel power_save=0 power_save_controller=N
EOF

# 2. Create udev rule to pin IRQ 130 to CPUs 0-3
UDEV_RULE='/etc/udev/rules.d/85-audio-irq.rules'
echo "Creating udev rule in $UDEV_RULE…"
sudo tee "$UDEV_RULE" > /dev/null <<'EOF'
# Pin the HDA Intel audio IRQ (130) across all four CPUs on boot
ACTION=="add", SUBSYSTEM=="irq", KERNEL=="130", \
  RUN+="/bin/sh -c 'echo 0-3 > /proc/irq/130/smp_affinity_list'"
EOF

# 3. Reload udev rules so it takes effect immediately
echo "Reloading udev rules…"
sudo udevadm control --reload
sudo udevadm trigger --subsystem-match=irq

echo "✅ Done. Power-save disabled, and IRQ affinity will now be set to 0-3 on every boot."
echo "You may reboot or re-plug your audio device to verify:"
echo "  cat /proc/irq/130/smp_affinity_list  # should show: 0-3"
