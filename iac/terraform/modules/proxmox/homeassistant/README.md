# Home Assistant Module

This Terraform module provisions Home Assistant virtual machines on Proxmox using cloud-init.

## Features

- Creates Home Assistant VMs on Ubuntu base
- Cloud-init configuration and customization
- Configures UEFI boot
- Enables QEMU guest agent for IP retrieval
- Supports custom VM specifications
- Pre-configured for Home Assistant setup

## Usage

```hcl
module "homeassistant" {
  source = "./modules/proxmox/homeassistant"

  vm_id         = 102
  vm_name       = "homeassistant"
  vm_description = "Home Assistant Instance"
  node_name     = "proxmox"

  vm_cores      = 2
  vm_memory     = 4096
  disk_size     = 32

  efi_storage_id = "local-lvm"
  disk_storage_id = "local-lvm"
}
```

## Prerequisites

- Proxmox node with SSH access
- Ubuntu template VM available (or use in combination with [template-ubuntu module](../template-ubuntu/))
- Cloud-init support on Proxmox

## Notes

- This module creates a Home Assistant VM with basic Ubuntu configuration
- Cloud-init handles initial setup and customization
- Guest agent is enabled for IP address retrieval
- UEFI boot recommended for better hardware support
- QEMU Q35 machine type for modern features

## Inputs

| Name                   | Description                   | Type     | Default       | Required |
| ---------------------- | ----------------------------- | -------- | ------------- | -------- |
| vm_id                  | Unique Proxmox VM ID          | `number` | n/a           | yes      |
| vm_name                | Name of the HA VM             | `string` | n/a           | yes      |
| vm_description         | VM description                | `string` | n/a           | yes      |
| node_name              | Proxmox node name             | `string` | n/a           | yes      |
| vm_cores               | Number of CPU cores           | `number` | `2`           | no       |
| vm_memory              | Memory in MB                  | `number` | `2048`        | no       |
| disk_size              | Disk size in GB               | `number` | `32`          | no       |
| vm_bios                | BIOS type (ovmf for EFI)      | `string` | `"ovmf"`      | no       |
| vm_machine             | QEMU machine type             | `string` | `"q35"`       | no       |
| vm_os                  | OS type for Proxmox           | `string` | `"l26"`       | no       |
| efi_storage_id         | Storage for EFI partition     | `string` | `"local-lvm"` | no       |
| disk_interface         | Disk interface type           | `string` | `"virtio0"`   | no       |
| disk_storage_id        | Storage location for disk     | `string` | `"local-lvm"` | no       |
| network_bridge         | Network bridge for VM         | `string` | `"vmbr0"`     | no       |
| ssh_public_key_content | SSH public key for cloud-init | `string` | n/a           | no       |

## Outputs

| Name    | Description                |
| ------- | -------------------------- |
| vm_id   | The Home Assistant VM ID   |
| vm_name | The Home Assistant VM name |

---

For production deployment, consider adding health checks and monitoring. See the main infrastructure documentation for deployment patterns.
