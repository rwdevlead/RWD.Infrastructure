#!/usr/bin/env bash

set -euo pipefail

: "${VM_USER:?VM_USER is required}"
: "${VM_IP:?VM_IP is required}"

echo "Step 1: Cleaning up internal OS state on ${VM_USER}@${VM_IP}..."

# Skip known_hosts persistence because this VM's SSH host keys are about to be wiped for templating
ssh -T \
  -o BatchMode=yes \
  -o PasswordAuthentication=no \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  -i ~/.ssh/id_ed25519 \
  "${VM_USER}@${VM_IP}" \
  bash -se << 'EOF'

    echo "Cleaning package cache..."
    sudo apt-get clean

    echo "Cleaning cloud-init state..."
    sudo cloud-init clean --logs --seed

    # Truncate instead of deleting so systemd preserves the file and generates a unique ID on clone boot
    echo "Resetting machine-id..."
    sudo truncate -s 0 /etc/machine-id

    # Force unique SSH host keys to be generated when cloned VMs boot
    echo "Removing SSH host keys..."
    sudo rm -f /etc/ssh/ssh_host_*

    # Shut down immediately so the sealed image cannot regenerate cloud-init or SSH state before templating
    echo "Shutdown immediately after cleanup..."
    sudo shutdown -h now
EOF

echo "Cleanup command sent successfully."
