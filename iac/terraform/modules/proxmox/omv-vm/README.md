# OpenMediaVault VM Module (Proxmox)

This module provisions the hardware "shell" for an OpenMediaVault (OMV) storage appliance on Proxmox VE.

## Scope

- **Terraform:** Manages CPU, RAM, OS Boot Disk (32GB default), EFI Disk, QEMU guest agent, and Physical Disk Passthrough.
- **Manual:** Initial OS installation via ISO (when installing) and initial Web UI configuration.
- **Ansible:** Manages storage filesystems, shared folders, users, and service configuration.

## Requirements

- Proxmox VE node with SSH enabled for root.
- A physical disk ID from `/dev/disk/by-id/` for data storage passthrough.
- An OpenMediaVault ISO located in a Proxmox storage pool, or `iso_file_id = "none"` when booting directly from disk after installation.

## Key Logic: Disk Passthrough

Because the Proxmox API restricts direct raw physical disk attachment in some configurations, this module uses a `null_resource` with `remote-exec` to execute `qm set` directly on the Proxmox host via SSH:

```bash
qm set ${var.vm_id} -scsi1 /dev/disk/by-id/${var.data_disk_id},serial=1,backup=0
```

## Inputs

| Name                      | Description                                              | Type          | Default               | Required |
| ------------------------- | -------------------------------------------------------- | ------------- | --------------------- | -------- |
| `boot_datastore`          | Storage location for the OS disk and EFI disk            | `string`      | `"local-lvm"`         | no       |
| `data_disk_id`            | Physical disk ID from `/dev/disk/by-id/` for passthrough | `string`      | n/a                   | yes      |
| `disk_interface`          | Disk interface type for the OS drive                     | `string`      | `"virtio0"`           | no       |
| `disk_size`               | Size of OS boot disk in GB                               | `number`      | `32`                  | no       |
| `iso_file_id`             | Path to OMV ISO (e.g. `local:iso/...`) or `"none"`        | `string`      | n/a                   | yes      |
| `network_gateway`         | Gateway IP for VM                                        | `string`      | `"dhcp"`              | no       |
| `proxmox_node_ip`         | IP address of the Proxmox host node                      | `string`      | n/a                   | yes      |
| `proxmox_node_name`       | The Proxmox node to deploy to                            | `string`      | n/a                   | yes      |
| `ssh_private_key_content` | Private SSH key content for Proxmox host connection      | `string`      | n/a                   | yes      |
| `tags`                    | Tags for the VM                                          | `set(string)` | `["omv"]`             | no       |
| `vm_bios`                 | BIOS type (ovmf for EFI)                                 | `string`      | `"ovmf"`              | no       |
| `vm_cores`                | Number of CPU cores                                      | `number`      | `2`                   | no       |
| `vm_description`          | Description of the VM                                    | `string`      | `"Virtual Machine"`   | no       |
| `vm_id`                   | Unique Proxmox VM ID                                     | `number`      | n/a                   | yes      |
| `vm_machine`              | Machine type of VM (pc, q35)                             | `string`      | `"q35"`               | no       |
| `vm_memory_max`           | Maximum memory in MB                                     | `number`      | `8192`                | no       |
| `vm_memory_min`           | Minimum memory in MB                                     | `number`      | `8192`                | no       |
| `vm_name`                 | Name of the OMV VM                                       | `string`      | `"omv"`               | no       |
| `vm_on_boot`              | Start VM on Proxmox node boot                            | `bool`        | n/a                   | yes      |
| `vm_static_ip`            | Static IP for VM                                         | `string`      | `null`                | no       |

## Outputs

| Name | Description |
| --- | --- |
| `vm_ipv4_address` | Assigned IPv4 address of the OMV VM (or status message via QEMU guest agent) |
| `vm_id` | The VM ID of the OMV instance |

## Usage

```hcl
module "omv_vm" {
  source            = "../../../modules/proxmox/omv-vm"
  vm_name           = "dev-omv-01"
  vm_id             = 102
  vm_description    = "Open Media Vault - Managed by Terraform"
  vm_on_boot        = false
  proxmox_node_name = "pve-p01"
  proxmox_node_ip   = "192.168.50.10"

  vm_cores      = 2
  vm_bios       = "ovmf"
  vm_machine    = "q35"
  vm_memory_max = 4096
  vm_memory_min = 4096

  boot_datastore = "local-lvm"
  iso_file_id    = "none"

  data_disk_id   = "ata-HGST_HTS541010A9E680_JA1009C033492P"
  disk_interface = "scsi0"
  disk_size      = 32

  network_gateway = "192.168.50.1"
  vm_static_ip    = "192.168.50.17/24"

  tags = ["vm", "dev", "omv", "storage"]

  ssh_private_key_content = local.ssh_private_key_content
}
```

## Provisioning Workflow

1. **Terraform:** Provisions the VM hardware shell, OS drive, EFI disk, and executes the remote SSH passthrough command (`qm set`) to attach the data drive.
2. **OS Install:** If installing from scratch, set `iso_file_id` to the installer ISO and complete installation via the Proxmox console. Ensure `qemu-guest-agent` is installed and running inside Debian (`apt install qemu-guest-agent && systemctl enable --now qemu-guest-agent`) for IP detection and graceful shutdown. Once installed, set `iso_file_id = "none"`.
3. **Web UI:** Access the OMV administration panel to configure storage file systems, users, and shares.
4. **Ansible:** Manage automated configurations, user groups, and services.
