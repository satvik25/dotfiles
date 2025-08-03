#!/usr/bin/env bash
# Watch /proc/acpi/button/lid/LID0/state by polling
STATE_FILE="/proc/acpi/button/lid/LID0/state"

# Make sure the file exists
if [[ ! -r "$STATE_FILE" ]]; then
  echo "ERROR: Cannot read $STATE_FILE"
  exit 1
fi

# Read initial state (“open” or “closed”)
prev_state=$(awk '{print $2}' "$STATE_FILE")

while true; do
  # Read current state
  cur_state=$(awk '{print $2}' "$STATE_FILE")
  
  # On transition to “open”, restart once
  if [[ "$cur_state" != "$prev_state" ]] && [[ "$cur_state" == "open" ]]; then
    echo "$(date +'%F %T') Lid opened → restarting gestures" >&2
    /usr/bin/libinput-gestures-setup restart
  fi
  
  prev_state="$cur_state"
  sleep 1
done
