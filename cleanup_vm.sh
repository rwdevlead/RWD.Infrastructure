#!/usr/bin/env bash

set -euo pipefail

# ---- Validate required env vars ----
: "${VM_USER:?VM_USER is required}"
: "${VM_IP:?VM_IP is required}"

echo "Step 1: Cleaning up internal OS state on ${VM_USER}@${VM_IP}..."

ssh -T \
  -o BatchMode=yes \
  -o PasswordAuthentication=no \
  "${VM_USER}@${VM_IP}" \
  bash -se << 'EOF'

    echo "Cleaning package cache..."
    sudo apt-get clean

    echo "Cleaning cloud-init state..."
    sudo cloud-init clean --logs --seed

    echo "Resetting machine-id..."
    sudo truncate -s 0 /etc/machine-id

    echo "Removing SSH host keys..."
    sudo rm -f /etc/ssh/ssh_host_*

    echo "Shutdown immediately after cleanup..."
    sudo shutdown -h now
EOF

echo "Cleanup command sent successfully."


