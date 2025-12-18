#!/usr/bin/env bash
# Install Agent, Clean Up, and Convert to Template

set -euo pipefail

# --- INPUT REQUIREMENTS (Export these variables before running) ---
: "${VMID:?VMID is required}"
: "${CI_USER:?CI_USER is required}"
: "${VM_IP:?VM_IP is required (The static or known IP of the VM)}"
: "${CI_PASSWORD:?CI_PASSWORD is required for temporary CI settings}"


# --- 1. CONFIGURE AND BOOT VM ---
echo "--- 1. CONFIGURING CLOUD-INIT AND STARTING VM ---"
# Set temporary Cloud-Init user/pass/network for initial SSH access
qm set "${VMID}" --ciuser "${CI_USER}"
qm set "${VMID}" --cipassword "${CI_PASSWORD}"
qm set "${VMID}" --ipconfig0 ip=dhcp

echo "== Starting VM $VMID =="
qm start "${VMID}"
echo "Waiting 60 seconds for VM to boot and SSH service to become available on ${VM_IP}..."
sleep 60 

# --- 2. INSTALL AGENT & CLEANUP (VIA SSH INSIDE VM) ---
echo "--- 2. INSTALLING AGENT & CANONICAL CLOUD-INIT CLEANUP ---"

# SSH into the VM to run commands. Authentication uses your SSH key.
ssh -o StrictHostKeyChecking=no -t "${CI_USER}@${VM_IP}" << 'SSH_COMMANDS'
    # Commands run INSIDE the VM
    set -euo pipefail
    
    echo "Installing qemu-guest-agent..."
    sudo apt update
    sudo apt install -y qemu-guest-agent
    
    # 1. Enable the agent (ensures it starts on every boot of future clones)
    echo "Enabling qemu-guest-agent service..."
    sudo systemctl enable qemu-guest-agent
    
    # 2. Start the agent (ensures Proxmox sees it during this current run)
    echo "Starting qemu-guest-agent service..."
    sudo systemctl start qemu-guest-agent
    
    # 3. Canonical Cloud-Init cleanup
    echo "Running canonical Cloud-Init cleanup: cloud-init clean --logs --seed"
    sudo cloud-init clean --logs --seed
    
    # 4. Final OS Cleanup (Clear shell history)
    history -c
    cat /dev/null > ~/.bash_history
    
    echo "Cleanup complete. Shutting down VM..."
    sudo shutdown now
SSH_COMMANDS

# --- 3. AWAIT SHUTDOWN AND CONVERT TO TEMPLATE (ON PROXMOX HOST) ---
echo "--- 3. AWAITING SHUTDOWN AND TEMPLATE CONVERSION ---"
# Wait for shutdown
while qm status "${VMID}" | grep -q "running"; do
    sleep 5
    echo "Waiting for VM shutdown...";
done
echo "VM ${VMID} is STOPPED."

# 1. Final Proxmox Host cleanup: Remove the temporary CI configuration
echo "== Clearing temporary Cloud-Init settings from VM config =="
qm set "${VMID}" --delete ciuser
qm set "${VMID}" --delete cipassword
qm set "${VMID}" --delete ipconfig0

# 2. Convert the VM to a template
echo "== Converting VM to Proxmox template =="
qm template "${VMID}"

echo "--- TEMPLATE CREATION COMPLETE! ---"







*****************

makefile call


