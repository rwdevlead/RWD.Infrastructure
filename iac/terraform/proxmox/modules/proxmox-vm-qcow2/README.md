# Terraform Module: Proxmox VM (QCOW2 Import)

This module creates a Proxmox virtual machine using a pre-existing QCOW2 disk image.

## Features

- Imports a QCOW2 disk into Proxmox storage
- Attaches the disk to a new VM
- Optional resizing and auto-start
- Works without cloud-init

## Example Usage

```hcl
module "proxmox_vm_qcow2" {
  source = "./modules/proxmox-vm-qcow2"

  proxmox_endpoint     = "https://proxmox.local:8006/api2/json"
  proxmox_token_id     = "terraform@pve!mytoken"
  proxmox_token_secret = "supersecret"
  node_name            = "pve01"
  vm_name              = "debian-custom"
  storage_pool         = "local-lvm"
  qcow2_path           = "/var/lib/vz/template/qcow2/debian-12.qcow2"
  disk_size_gb         = 20
  start_vm             = true
}
```
