#!/bin/bash
# init_vm.sh (Template Initialization)

echo "--- 4. INITIALIZING CLOUD-INIT USER AND SHUTTING DOWN ---"
echo "== 4.1 Setting CloudInit user $CI_USER + password =="
qm set $VMID --ciuser $CI_USER
qm set $VMID --cipassword "$CI_PASSWORD"
echo "== 4.2 Setting DHCP network for CloudInit =="
qm set $VMID --ipconfig0 ip=dhcp
echo "== 4.3 Booting VM ONCE to initialize cloud-init =="
qm start $VMID

# Wait a fixed amount of time for the necessary initialization to run (user creation, etc.)
echo "Waiting 120 seconds for cloud-init to run..."
sleep 120 

echo "== 4.4 Shutting down VM =="
# Use 'qm stop' for maximum reliability in an automated script if 'shutdown' fails.
qm shutdown $VMID
echo "Waiting for VM to fully shut down..."
while qm status $VMID | grep -q "running"; do
    sleep 5
    echo "Waiting for VM shutdown...";
done
echo "VM $VMID is STOPPED."

echo "== 4.5 Converting VM to Template =="
qm template $VMID
echo "VM $VMID is now a template and ready for cloning."