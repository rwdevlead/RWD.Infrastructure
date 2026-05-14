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

  # Configuration...
}

# Development Docker VM
module "Dev_Docker_01" {
  source = "../../../modules/proxmox/clone-vm"

  tempate_node_id   = module.ubuntu_template.template_id
  tempate_node_name = module.ubuntu_template.template_node_name

  vm_id        = 201
  vm_name      = "dev-docker-01"
  vm_node_name = "proxmox"
  vm_static_ip = "192.168.50.12/24"

  # Configuration...
}
```

## Network Configuration

All VMs are connected to bridge `vmbr0` for LAN access.

| VM Name         | IP Address       | Purpose            |
| --------------- | ---------------- | ------------------ |
| ubuntu-template | N/A              | Template (off)     |
| dev-docker-01   | 192.168.50.12/24 | Development Docker |
| homeassistant   | Dynamic (DHCP)   | Home Automation    |

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

1. **Proxmox API Token**
   - Create in Proxmox UI: Datacenter > Permissions > API Tokens
   - Required scopes: Datastore, Nodes, VMs, Firewall

2. **Environment Variables**

   ```bash
   export PROXMOX_VE_ENDPOINT="https://proxmox.example.com:8006"
   export PROXMOX_VE_API_TOKEN="user@pam!terraform=<token>"
   export PROXMOX_VE_INSECURE=true
   ```

3. **SSH Keys**
   - Public key: `~/.ssh/id_ed25519.pub`
   - Private key: `~/.ssh/id_ed25519`

### Initialize

```bash
terraform init
```

### Plan Changes

```bash
terraform plan
```

### Apply Configuration

```bash
terraform apply
```

### Destroy (CAUTION)

```bash
# WARNING: This will delete all VMs!
terraform destroy
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
  vm_static_ip = "192.168.50.13/24"

  vm_cores      = 2
  vm_memory_min = 4096
  vm_memory_max = 8192
  disk_size     = 40

  ssh_public_key_content = local.ssh_public_key_content
}
```

2. Apply changes:

```bash
terraform plan
terraform apply
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
