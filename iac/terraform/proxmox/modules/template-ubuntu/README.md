# Ubuntu Template Module

This Terraform module creates Ubuntu VM templates on Proxmox using cloud-init for initial configuration.

## Features

- Provisions Ubuntu VMs from cloud images
- Configures cloud-init for user setup and package installation
- Prepares VMs for template conversion
- Supports UEFI boot configuration

## Usage

```hcl
module "ubuntu_template" {
  source = "./modules/template-ubuntu"

  node_name = "proxmox-node"
  vm_id     = 9000
  vm_name   = "ubuntu-template"

  vm_cores  = 2
  vm_memory = 4096
}
```

## Workflow

1. **Provision**: Terraform creates a "Base VM" from a cloud image
2. **Initialize**: Cloud-init installs the Guest Agent and sets up SSH keys
3. **Seal**: Use external scripts to clean the VM and convert to template
4. **Convert**: The VM becomes a read-only template for cloning

## Prerequisites

- SSH agent with loaded keys for Proxmox access
- Passwordless SSH access to Proxmox host as root
- Public key configured in cloud-init for VM access

## Important Notes

- Include `ignore_changes = [template, started]` in lifecycle blocks
- The module creates VMs in writable state initially
- External scripts handle the sealing and templating process

## Inputs

| Name                  | Description           | Type           | Default      | Required |
| --------------------- | --------------------- | -------------- | ------------ | -------- |
| node_name             | Proxmox node name     | `string`       | n/a          | yes      |
| vm_id                 | Template VM ID        | `number`       | n/a          | yes      |
| vm_name               | VM/template name      | `string`       | `"template"` | no       |
| vm_os                 | Operating system type | `string`       | `"l26"`      | no       |
| vm_bios               | BIOS type             | `string`       | `"ovmf"`     | no       |
| vm_machine            | Machine type          | `string`       | `"q35"`      | no       |
| vm_cores              | CPU cores             | `number`       | `2`          | no       |
| vm_memory             | Memory in MB          | `number`       | `2048`       | no       |
| efi_storage_id        | EFI storage location  | `string`       | n/a          | yes      |
| disk_storage_id       | Disk storage location | `string`       | n/a          | yes      |
| disk_size             | Disk size in GB       | `number`       | `20`         | no       |
| cloud_init_storage_id | Cloud-init storage    | `string`       | n/a          | yes      |
| cloud_init_user       | Cloud-init username   | `string`       | n/a          | yes      |
| cloud_init_ssh_keys   | SSH public keys       | `list(string)` | n/a          | yes      |
| cloud_init_packages   | Packages to install   | `list(string)` | `[]`         | no       |

## Outputs

| Name               | Description        |
| ------------------ | ------------------ |
| template_id        | The template VM ID |
| template_node_name | Proxmox node name  |

---

This module works in conjunction with external scripts for the template sealing process. See the main Terraform README for template creation workflows.
