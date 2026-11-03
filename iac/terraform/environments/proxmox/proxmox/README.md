# Proxmox Development/Test Environment - Terraform

This directory contains the Terraform configuration for the development/test Proxmox cluster.

## Environment Overview

- **Proxmox Node:** `proxmox`
- **Purpose:** Development, testing, and template development
- **Infrastructure:** Development Docker host, Home Assistant, and Ubuntu templates
- **Network:** 192.168.50.0/24

## Virtual Machines

### Templates

#### ubuntu-2404-template (VM ID: 901)

Ubuntu 24.04 LTS template for cloning.

- **Status:** Typically powered off (template mode)
- **Hardware:** 2 CPU cores, 4096 MB RAM, 20 GB disk
- **Boot:** EFI (OVMF), UEFI firmware
- **OS:** Ubuntu 24.04 (cloud-images)
- **SSH:** Public key injection via cloud-init
- **ISO Source:** Ubuntu cloud images

**Note:** This template is created and updated using the workflow described in the main Terraform README.

### VMs

#### dev-docker-01 (VM ID: 201)

Development Docker host for testing containers and services.

- **Status:** Running
- **Hardware:** 2 CPU cores, 4-8 GB RAM (dynamic), 40 GB disk
- **Network:** Static IP `192.168.50.12/24`
- **OS:** Ubuntu 24.04 (cloned from template)
- **User:** ka8kgj
- **Use Case:** Development and testing Docker services

#### homeassistant (VM ID: 102)

Home Assistant smart home server.

- **Status:** Running
- **Hardware:** 2 CPU cores, 4096 MB RAM, 32 GB disk
- **Network:** Dynamic IP (DHCP)
- **OS:** Ubuntu 24.04 (via template)
- **Use Case:** Home automation and smart home management

#### dev-truenas-01 (VM ID: 200)

TrueNAS SCALE storage appliance for development network storage.

- **Status:** Running
- **Hardware:** 2 CPU cores, 8192 MB RAM, 32 GB boot disk
- **Data Disk:** Physical disk passthrough (`ata-ST1000DM003-1ER162_Z4YCRN9L`)
- **Network:** Static IP `192.168.50.13/24`
- **Use Case:** Development network storage and backups

## Configuration Structure

```hcl
# SSH Key Management
locals {
  ssh_public_key_content  = trimspace(file("~/.ssh/id_ed25519.pub"))
  ssh_private_key_content = file("~/.ssh/id_ed25519")
}

# Ubuntu Template (initially false, converted to template later)
module "ubuntu_template" {
  source = "../../../modules/proxmox/template-ubuntu"

  vm_id         = 901
  vm_name       = "ubuntu-2404-template"
  node_name     = "proxmox"
  template_mode = false  # See template creation workflow
  vm_startup    = false

  # Configuration...
}

# Development Docker VM
module "Dev_Docker_01" {
  source = "../../../modules/proxmox/clone-vm"

  tempate_node_id   = module.ubuntu_template.template_id
  tempate_node_name = module.ubuntu_template.template_node_name

  vm_id          = 201
  vm_name        = "dev-docker-01"
  vm_node_name   = "proxmox"
  vm_on_boot     = false
  vm_static_ip   = "192.168.50.12/24"

  # Configuration...
}

# Home Assistant VM
module "homeassistant" {
  source = "../../../modules/proxmox/homeassistant"

  vm_id          = 102
  node_name      = "proxmox"
  vm_name        = "homeassistant"
  vm_on_boot     = false

  # Configuration...
}

# TrueNAS Storage VM
module "truenas_vm" {
  source            = "../../../modules/proxmox/truenas-vm"
  vm_name           = "dev-truenas-01"
  vm_id             = 200
  vm_on_boot        = false
  proxmox_node_name = "proxmox"
  proxmox_node_ip   = "192.168.50.11"
  data_disk_id      = "ata-ST1000DM003-1ER162_Z4YCRN9L"

  # Configuration...
}
```

## Network Configuration

All VMs are connected to bridge `vmbr0` for LAN access.

| VM Name         | IP Address       | Purpose                 |
| --------------- | ---------------- | ----------------------- |
| ubuntu-template | N/A              | Template (off)          |
| dev-docker-01   | 192.168.50.12/24 | Development Docker host |
| homeassistant   | Dynamic (DHCP)   | Home Automation         |
| dev-truenas-01  | 192.168.50.13/24 | TrueNAS Storage         |

**Gateway:** 192.168.50.1
**DNS:** Configured via DHCP

## Template Creation Workflow

### Initial Setup (template_mode = false)

1. Create as normal VM:

   ```bash
   terraform apply
   ```

2. VM boots and cloud-init runs

3. Run cleanup scripts on the host:
   ```bash
   make cleanup-vm
   make convert-to-template
   ```

### Template Conversion (template_mode = true)

1. Update `template_mode = true` in configuration

2. Apply changes:

   ```bash
   terraform apply
   ```

3. Terraform stops the VM and converts it to template

### Cloning from Template

Once template is created, clone VMs for development:

```hcl
module "dev_docker" {
  source = "../../../modules/proxmox/clone-vm"

  tempate_node_id   = module.ubuntu_template.template_id
  tempate_node_name = module.ubuntu_template.template_node_name

  vm_id        = 201
  vm_name      = "dev-docker-01"
  vm_on_boot   = false
  # ... other configuration
}
```

## SSH Access

All VMs are accessible via SSH using the injected public key:

```bash
# Access dev-docker-01
ssh ka8kgj@192.168.50.12

# Access via hostname (if DNS configured)
ssh ka8kgj@dev-docker-01.local
```

## Working with This Environment

### Prerequisites

- **HCP Terraform Token:** Run `terraform login` to authenticate with HCP Terraform (`app.terraform.io`) for remote state in the `proxmox-legacy` workspace. The token is stored locally in `~/.terraform.d/credentials.tfrc.json`.
- **Not Stored in Infisical:** **The Terraform Cloud user API token is NOT stored in Infisical.** It must be generated and maintained on your local workstation via `terraform login`.
- **Infisical Secrets:** Universal Auth credentials configured in `.env` (`INFISICAL_CLIENT_ID`, `INFISICAL_CLIENT_SECRET`, `INFISICAL_PROJECT_ID`). Proxmox host connection secrets (`PVE_ENDPOINT`, `PVE_TOKEN`) are stored in and dynamically retrieved from the Infisical vault at `/terraform/proxmox/proxmox`.

All operations should be performed via the repository root Makefile:

### Initialize

```bash
make init TARGET=proxmox/proxmox
```

### Plan Changes

```bash
make plan TARGET=proxmox/proxmox
```

### Apply Configuration

```bash
make apply TARGET=proxmox/proxmox
```

## Common Tasks

### Creating a New Development VM

1. Add module to `main.tf`:

```hcl
module "dev_test_vm" {
  source = "../../../modules/proxmox/clone-vm"

  tempate_node_id   = module.ubuntu_template.template_id
  tempate_node_name = module.ubuntu_template.template_node_name

  vm_id        = 202
  vm_name      = "dev-test-02"
  vm_node_name = "proxmox"
  vm_on_boot   = false
  vm_static_ip = "192.168.50.15/24"

  vm_cores      = 2
  vm_memory_min = 4096
  vm_memory_max = 8192
  disk_size     = 40

  ssh_public_key_content = local.ssh_public_key_content
}
```

2. Apply changes:

```bash
make plan TARGET=proxmox/proxmox
make apply TARGET=proxmox/proxmox
```

### Updating VM Hardware

Edit the module parameters and apply:

```bash
# Edit main.tf to change vm_cores, vm_memory_max, etc.
terraform plan
terraform apply
```

### Adding Home Assistant Configuration

The Home Assistant module can be extended with additional configuration via cloud-init or Ansible.

## Important Notes

- **VM IDs:** Development uses 9xx for templates, 1xx-2xx for VMs
- **Storage:** Uses `local-lvm` for disk storage
- **BIOS:** All VMs use OVMF (EFI) boot
- **Machine Type:** QEMU Q35 for better hardware support
- **OS:** Ubuntu 24.04 LTS cloud image
- **Guest Agent:** Installed for VM management and IP retrieval

## Troubleshooting

### VM Not Getting IP Address

1. Check cloud-init status on VM:

   ```bash
   ssh ka8kgj@192.168.50.12 cloud-init status
   ```

2. Verify DHCP is configured in cloud-init

3. Check Proxmox guest agent is running:
   ```bash
   ssh ka8kgj@192.168.50.12 systemctl status qemu-guest-agent
   ```

### Template Not Initialized

Ensure `template_mode = false` initially and VM has booted completely before attempting to convert to template.

## See Also

- [Proxmox Modules Documentation](../../../modules/proxmox/)
- [Main Proxmox Environment README](../README.md)
- [Main Terraform README](../README.md)
