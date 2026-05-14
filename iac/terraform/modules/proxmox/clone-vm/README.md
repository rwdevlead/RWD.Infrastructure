# Clone VM Module

This Terraform module clones virtual machines from existing templates on Proxmox.

## Features

- Clones VMs from Proxmox templates
- Configures CPU, memory, disk, and network settings
- Static IP address configuration
- Cloud-init customization (username, password, SSH keys)
- QEMU guest agent for IP address retrieval
- EFI boot support
- Automatic VM startup

## Usage

```hcl
module "dev_docker" {
  source = "./modules/clone-vm"

  tempate_node_id   = module.ubuntu_template.template_id
  tempate_node_name = module.ubuntu_template.template_node_name

  vm_id          = 201
  vm_name        = "dev-docker-01"
  vm_node_name   = "proxmox"
  vm_description = "Development Docker Host"

  vm_username = "ubuntu"
  vm_password = "password123"
  vm_cores    = 2
  vm_memory_min = 4096
  vm_memory_max = 8192
  disk_size   = 40

  vm_static_ip = "192.168.50.12/24"
  network_gateway = "192.168.50.1"

  ssh_public_key_content = file("~/.ssh/id_ed25519.pub")
}
```

## Features

- Full clone for complete independence from template
- Cloud-init for user and SSH key configuration
- Static IP configuration
- Dynamic memory allocation (min/max)
- EFI boot with UEFI firmware

## Notes

- Full cloning ensures cloned VMs are completely independent
- Cloud-init handles user creation, SSH key injection, and initial configuration
- QEMU guest agent is started automatically for IP retrieval
- IP addresses may not be immediately available during initial boot
- VM starts powered off; it powers on after cloud-init completes

## Inputs

| Name                   | Description                         | Type     | Default             | Required |
| ---------------------- | ----------------------------------- | -------- | ------------------- | -------- |
| tempate_node_id        | Template VM ID                      | `number` | n/a                 | yes      |
| tempate_node_name      | Proxmox node where template resides | `string` | n/a                 | yes      |
| vm_id                  | Unique ID for new VM                | `number` | n/a                 | yes      |
| vm_name                | Name of the cloned VM               | `string` | n/a                 | yes      |
| vm_node_name           | Proxmox node for the VM             | `string` | n/a                 | yes      |
| vm_username            | Cloud-init username                 | `string` | n/a                 | no       |
| vm_password            | Cloud-init password                 | `string` | n/a                 | no       |
| vm_cores               | Number of CPU cores                 | `number` | `2`                 | no       |
| vm_memory_min          | Minimum memory in MB                | `number` | `2048`              | no       |
| vm_memory_max          | Maximum memory in MB (0 = no limit) | `number` | `0`                 | no       |
| vm_description         | VM description                      | `string` | `"Virtual Machine"` | no       |
| disk_size              | Disk size in GB                     | `number` | `32`                | no       |
| disk_interface         | Disk interface type                 | `string` | `"virtio0"`         | no       |
| disk_storage_id        | Storage location for disk           | `string` | `"local-lvm"`       | no       |
| vm_static_ip           | Static IP in CIDR format            | `string` | n/a                 | no       |
| network_gateway        | Default network gateway             | `string` | `"192.168.50.1"`    | no       |
| network_bridge         | Network bridge for VM               | `string` | `"vmbr0"`           | no       |
| network_device_model   | Network device model                | `string` | `"virtio"`          | no       |
| vm_machine             | QEMU machine type                   | `string` | `"q35"`             | no       |
| vm_bios                | BIOS type (ovmf for EFI)            | `string` | `"ovmf"`            | no       |
| vm_os                  | OS type for Proxmox                 | `string` | `"l26"`             | no       |
| efi_storage_id         | Storage for EFI partition           | `string` | `"local-lvm"`       | no       |
| ssh_public_key_content | SSH public key for cloud-init       | `string` | n/a                 | no       |
| keyboard               | Keyboard layout                     | `string` | `"en-us"`           | no       |

## Outputs

| Name            | Description                           |
| --------------- | ------------------------------------- |
| vm_ipv4_address | VM's IPv4 address (or status message) |
