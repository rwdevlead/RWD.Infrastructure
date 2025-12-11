#!/bin/bash
# finalize_template.sh - Now using explicit --delete flags

echo "--- 5. FINALIZING AND CONVERTING TO TEMPLATE ---"
echo "== 5.1 Clearing CloudInit user/pass/network settings from VM =="

# Use --delete to explicitly remove the configuration keys
qm set $VMID --delete ciuser
qm set $VMID --delete cipassword
qm set $VMID --delete ipconfig0

echo "Settings cleared."

echo "== 5.2 Converting VM to Proxmox template =="
qm template $VMID

echo "== 5.3 Cleaning up downloaded image file =="
rm -f $IMG_FILE

echo "== 5.4 Verification: VM status (should show 'template') =="
qm status $VMID
echo "--- TEMPLATE FINALIZATION COMPLETE! ---"