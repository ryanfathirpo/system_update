#!/bin/bash

# Simple script to get local active IP addresses
get_local_ips() {
  # Try ip command first (Linux)
  if command -v ip &>/dev/null; then
    ip -4 addr show | grep -E 'inet ' | awk '{print $2}' | cut -d/ -f1 | grep -e '10\.6\.53\.' -e '10\.7\.31\.' # If you want all the addresses use: grep -v '^127\.' anything but 127
  # Fallback to ifconfig (macOS/BSD)
  elif command -v ifconfig &>/dev/null; then
    ifconfig | grep -E 'inet ' | grep -E '10\.' | awk '{print $2}'
  # Fallback to hostname
  else
    hostname -I 2>/dev/null || hostname -i 2>/dev/null || echo "Unable to determine IP"
  fi
}

IP=$(get_local_ips)
DNS='10.7.31.5'
ZONE='rlab.lan'
RECORD="$HOSTNAME.rlab.lan"
cat <<EOL | nsupdate
server $DNS
zone $ZONE
update delete $RECORD A
update add $RECORD 3600 A $IP
send
EOL
