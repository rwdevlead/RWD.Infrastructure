#!/usr/bin/env bash
set -euo pipefail

# ---- Required environment variables ----
: "${PROXMOX_NODE:?PROXMOX_NODE is required (hostname or IP)}"
: "${VM_ID:?VM_ID is required}"

echo "Step 2: Waiting for VM ${VM_ID} to shut down on ${PROXMOX_NODE}..."

until ssh -T root@"${PROXMOX_NODE}" "qm status ${VM_ID}" | grep -q "stopped"; do
    sleep 2
done

echo "VM ${VM_ID} is stopped."

echo "Step 3: Converting VM ${VM_ID} to a Proxmox template..."

ssh -T \
  -o BatchMode=yes \
  -o PasswordAuthentication=no \
  root@"${PROXMOX_NODE}" "qm template ${VM_ID}"

echo "Success! VM ${VM_ID} is now a template."

