#!/bin/bash

CTID=$1
HOSTNAME=$2
PASSWORD=${3:-changeme}

TEMPLATE="local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst" #Change to your template of your choice
STORAGE="local-lvm"
DISK_SIZE="8"
MEMORY="2048"
CORES="2"
BRIDGE="vmbr0"
SETUP_SCRIPT="/var/lib/lxc-scripts/setup.sh"

if [[ -z "$CTID" || -z "$HOSTNAME" ]]; then
  echo "Usage: $0 <ctid> <hostname> [password]"
  exit 1
fi

if [[ ! -f "$SETUP_SCRIPT" ]]; then
  echo "Setup script not found at $SETUP_SCRIPT"
  exit 1
fi

echo "Creating container $CTID ($HOSTNAME)..."

pct create "$CTID" "$TEMPLATE" \
  --hostname "$HOSTNAME" \
  --cores "$CORES" \
  --memory "$MEMORY" \
  --net0 name=eth0,bridge="$BRIDGE",ip=dhcp \
  --rootfs "${STORAGE}:${DISK_SIZE}" \
  --password "$PASSWORD"

echo "Starting container $CTID..."
pct start "$CTID"

sleep 5

echo "Uploading setup script..."
pct push "$CTID" "$SETUP_SCRIPT" /root/setup.sh
pct exec "$CTID" -- chmod +x /root/setup.sh

echo "Creating systemd service to run setup.sh once..."

read -r -d '' SERVICE <<EOF
[Unit]
Description=Run initial setup script once
After=network.target

[Service]
Type=oneshot
ExecStart=/root/setup.sh
TimeoutSec=300 
RemainAfterExit=no

[Install]
WantedBy=multi-user.target
EOF

echo "$SERVICE" > /tmp/setup-provision.service

pct push "$CTID" /tmp/setup-provision.service /etc/systemd/system/setup-provision.service
rm /tmp/setup-provision.service

pct exec "$CTID" -- systemctl enable setup-provision.service

echo "Restarting container $CTID to trigger setup..."
pct stop "$CTID"
pct start "$CTID"

echo "Setup service enabled and container restarted."
echo "Root password is: $PASSWORD"
