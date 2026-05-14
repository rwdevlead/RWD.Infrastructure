# Ubuntu Template Module

This Terraform module creates Ubuntu VM templates on Proxmox using cloud-init for initial configuration.

## Features

- Provisions Ubuntu VMs from official cloud images
- Cloud-init for SSH key injection and configuration
- Flexible template or VM mode operation
- UEFI boot support (EFI)
- Configurable hardware (CPU, RAM, disk)
- Optional automatic startup
- Tag support for organization

## Workflow

1. **Provision** (template_mode=false):
   - Terraform creates VM from cloud image
   - Cloud-init runs for initial setup
   - VM boots and prepares for sealing
   -
2. **Seal**:
   - Run external cleanup scripts via `make cleanup-vm`
   - Clears logs, SSH keys, machine-id
   - Prepares for templating

3. **Convert** (template_mode=true):
   - Update module to set `template_mode = true`
   - Run `terraform apply`
   - Terraform stops VM and converts to template

4. **Clone**: Use [clone-vm module](../clone-vm/) to create VMs from template

## Usage

```hcl
# Step 1: Create as VM for sealing
module "ubuntu_template" {
  source = "./modules/proxmox/template-ubuntu"

  vm_id         = 901
  vm_name       = "ubuntu-2404-template"
  node_name     = "proxmox"
  template_mode = false  # Initially create as VM
  vm_startup    = false

  vm_cores      = 2
  vm_memory     = 4096
  disk_size     = 20

  iso_url               = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
  iso_checksum          = "d8f7f427a53c221feee90d47ca008d89237e206a2d4935c98b84eefdbf52f41d"
  iso_checksum_algorithm = "sha256"

  ssh_public_key_content = file("~/.ssh/id_ed25519.pub")

  tags = ["template", "linux"]
}

# After sealing:
# Step 2: Convert to template
# Update to template_mode = true, then apply again
```

## Prerequisites

- SSH access to Proxmox host
- SSH public key for cloud-init injection
- Ubuntu cloud image available (ISO) or URL accessible

## Important Notes

- **Initial Creation**: Set `template_mode = false` and `vm_startup = false`
- **Sealing**: Run `make cleanup-vm` from project root after VM boot
- **Template Conversion**: Set `template_mode = true` and apply
- **No Guest Agent**: Cloud images don't include guest agent initially
- **Cloud-init**: Handles SSH key injection for secure access

## Template Sealing

Before converting to template, the sealing process:

- Clears system logs (`/var/log/*`)
- Removes SSH host keys
- Clears machine-id for unique identifiers on clones
- Prepares filesystem for templating

## Inputs

| Name                   | Description                      | Type           | Default        | Required |
| ---------------------- | -------------------------------- | -------------- | -------------- | -------- |
| vm_id                  | Unique Proxmox VM ID             | `number`       | n/a            | yes      |
| vm_name                | VM/template name                 | `string`       | n/a            | yes      |
| node_name              | Proxmox node name                | `string`       | n/a            | yes      |
| template_mode          | Convert to template (true/false) | `bool`         | `true`         | no       |
| vm_startup             | Auto-start on Proxmox boot       | `bool`         | `false`        | no       |
| vm_cores               | CPU cores                        | `number`       | `2`            | no       |
| vm_memory              | Memory in MB                     | `number`       | `4096`         | no       |
| efi_storage_id         | Storage for EFI partition        | `string`       | `"local-lvm"`  | no       |
| vm_bios                | BIOS type (ovmf for EFI)         | `string`       | `"ovmf"`       | no       |
| vm_machine             | QEMU machine type                | `string`       | `"q35"`        | no       |
| vm_os                  | OS type for Proxmox              | `string`       | `"l26"`        | no       |
| disk_size              | Disk size in GB                  | `number`       | `20`           | no       |
| disk_interface         | Disk interface type              | `string`       | `"virtio0"`    | no       |
| disk_storage_id        | Storage location for disk        | `string`       | `"local-lvm"`  | no       |
| network_bridge         | Network bridge for VM            | `string`       | `"vmbr0"`      | no       |
| iso_target             | Storage pool for ISO             | `string`       | `"local"`      | no       |
| iso_url                | URL to Ubuntu cloud image        | `string`       | Ubuntu noble   | no       |
| iso_checksum           | SHA256 checksum of cloud image   | `string`       | Noble checksum | no       |
| iso_checksum_algorithm | Checksum algorithm               | `string`       | `"sha256"`     | no       |
| ssh_public_key_content | SSH public key for cloud-init    | `string`       | n/a            | yes      |
| keyboard               | Keyboard layout                  | `string`       | `"en-us"`      | no       |
| tags                   | Resource tags                    | `list(string)` | `[]`           | no       |

## Outputs

| Name               | Description        |
| ------------------ | ------------------ |
| template_id        | The template VM ID |
| template_node_name | Proxmox node name  |

---

See the [main Terraform README](../../../README.md#proxmox-template-creation-workflow) for detailed template creation workflow.
