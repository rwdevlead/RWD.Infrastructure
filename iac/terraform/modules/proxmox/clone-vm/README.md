# Clone VM Module

This Terraform module clones virtual machines from existing templates on Proxmox.

## Features

- Clones VMs from Proxmox templates
- Configures CPU, memory, and disk settings
- Enables QEMU guest agent for IP address retrieval
- Supports full cloning for independence

## Usage

```hcl
module "cloned_vm" {
  source = "./modules/clone-vm"

  vm_name        = "my-cloned-vm"
  vm_description = "Cloned Ubuntu VM"
  vm_node_name   = "proxmox-node"
  tempate_node_name = "proxmox-node"
  tempate_node_id   = 100  # Template VM ID

  vm_cores  = 2
  vm_memory = 4096
  vm_disk_size = 32
}
```

## Notes

- The QEMU guest agent must be installed and enabled in the template VM via cloud-init
- Full cloning (`clone.full = true`) ensures the cloned VM is completely independent
- IP addresses are retrieved using the guest agent

## Inputs

| Name              | Description                         | Type     | Default | Required |
| ----------------- | ----------------------------------- | -------- | ------- | -------- |
| vm_name           | Name of the cloned VM               | `string` | n/a     | yes      |
| vm_description    | VM description                      | `string` | n/a     | yes      |
| vm_node_name      | Proxmox node for the VM             | `string` | n/a     | yes      |
| tempate_node_name | Proxmox node where template resides | `string` | n/a     | yes      |
| tempate_node_id   | Template VM ID                      | `number` | n/a     | yes      |
| vm_cores          | Number of CPU cores                 | `number` | `2`     | no       |
| vm_memory         | Memory in MB                        | `number` | `2048`  | no       |
| vm_disk_size      | Disk size in GB                     | `number` | `20`    | no       |
| vm_machine        | Machine type                        | `string` | `"q35"` | no       |
| vm_os             | Operating system type               | `string` | `"l26"` | no       |

## Outputs

| Name         | Description                              |
| ------------ | ---------------------------------------- |
| vm           | The cloned virtual machine               |
| ipv4_address | VM's IPv4 address (requires guest agent) |
