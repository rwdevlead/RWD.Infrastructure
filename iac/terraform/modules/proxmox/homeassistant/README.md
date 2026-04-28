# Home Assistant Module

This Terraform module provisions Home Assistant virtual machines on Proxmox.

## Features

- Creates Home Assistant OS VMs
- Uses pre-downloaded HA OS image files
- Configures UEFI boot (required for HA OS)
- Enables QEMU guest agent
- Supports custom VM specifications

## Usage

```hcl
module "home_assistant" {
  source = "./modules/homeassistant"

  vm_name        = "home-assistant"
  vm_description = "Home Assistant Smart Home Server"
  node_name      = "proxmox-node"
  vm_id          = 200

  vm_cores  = 2
  vm_memory = 4096
  vm_disk_size = 32
}
```

## Requirements

- Home Assistant OS image file must be placed in the `files/` directory
- The image should be extracted from the .xz download from the Home Assistant website
- UEFI boot is required for Home Assistant OS

## Notes

- The module uses `proxmox_virtual_environment_file` to upload the local HA image
- Ensure the image file is named appropriately (e.g., `haos_ova-16.3.img`)
- The VM is configured with UEFI BIOS as required by HA OS

## Inputs

| Name           | Description         | Type     | Default  | Required |
| -------------- | ------------------- | -------- | -------- | -------- |
| vm_name        | Name of the HA VM   | `string` | n/a      | yes      |
| vm_description | VM description      | `string` | n/a      | yes      |
| node_name      | Proxmox node name   | `string` | n/a      | yes      |
| vm_id          | Unique VM ID        | `number` | n/a      | yes      |
| vm_cores       | Number of CPU cores | `number` | `2`      | no       |
| vm_memory      | Memory in MB        | `number` | `2048`   | no       |
| vm_disk_size   | Disk size in GB     | `number` | `32`     | no       |
| vm_bios        | BIOS type           | `string` | `"ovmf"` | no       |
| vm_machine     | Machine type        | `string` | `"q35"`  | no       |

## Outputs

| Name         | Description                              |
| ------------ | ---------------------------------------- |
| vm           | The Home Assistant virtual machine       |
| ipv4_address | VM's IPv4 address (requires guest agent) |
