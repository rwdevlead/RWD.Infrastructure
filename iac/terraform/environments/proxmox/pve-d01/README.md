# Proxmox Development Standalone Node (pve-d01) - Terraform

This directory contains the Terraform configuration for the `pve-d01` standalone development Proxmox node.

## Environment Overview

- **Proxmox Node:** `pve-d01`
- **Purpose:** Development staging and secondary container workloads
- **Storage Pool:** `local-zfs`
- **Network:** 192.168.50.0/24
- **Gateway:** 192.168.50.1

## Virtual Machines

### Templates

#### ubuntu-2404-template (VM ID: 901)

Ubuntu 24.04 LTS template for cloning development VMs on `pve-d01`.

- **Status:** Powered off (template mode)
- **Hardware:** 2 CPU cores, 4096 MB RAM, 20 GB disk
- **Storage:** `local-zfs`
- **Boot:** EFI (OVMF), UEFI firmware
- **OS:** Ubuntu 24.04 (cloud-images)
- **SSH:** Public key injection via cloud-init
- **ISO Source:** Ubuntu cloud images

### VMs

#### dev-docker-02 (VM ID: 101)

Development Docker host for running staging containers and services.

- **Status:** Running
- **Hardware:** 2 CPU cores, 4-8 GB RAM (dynamic), 40 GB disk
- **Storage:** `local-zfs`
- **Network:** Static IP `192.168.50.16/24`
- **OS:** Ubuntu 24.04 (cloned from template)
- **Start on Boot:** `false` (`vm_on_boot = false`)
- **User:** Configured via `default_username` / `default_password`
- **Use Case:** Staging and development Docker services

## Configuration Structure

```hcl
# SSH Key Management
locals {
  ssh_public_key_content  = trimspace(file("~/.ssh/id_ed25519.pub"))
  ssh_private_key_content = file("~/.ssh/id_ed25519")
}

# Ubuntu Template
module "ubuntu_template" {
  source        = "../../../modules/proxmox/template-ubuntu"
  vm_id         = 901
  vm_name       = "ubuntu-2404-template"
  node_name     = "pve-d01"
  template_mode = true
  vm_startup    = false

  efi_storage_id  = "local-zfs"
  disk_storage_id = "local-zfs"
  disk_size       = 20
  disk_interface  = "virtio0"
  network_bridge  = "vmbr0"

  ssh_public_key_content = local.ssh_public_key_content
}

# Development Docker VM
module "Dev_Docker_02" {
  source = "../../../modules/proxmox/clone-vm"

  tempate_node_id   = module.ubuntu_template.template_id
  tempate_node_name = module.ubuntu_template.template_node_name

  vm_id          = 101
  vm_node_name   = "pve-d01"
  vm_name        = "dev-docker-02"
  vm_description = "Development Docker Instance"
  vm_on_boot     = false

  vm_username = var.default_username
  vm_password = var.default_password

  vm_cores      = 2
  vm_memory_min = 4096
  vm_memory_max = 8192

  efi_storage_id  = "local-zfs"
  disk_storage_id = "local-zfs"
  disk_size       = 40
  disk_interface  = "virtio0"

  network_gateway      = "192.168.50.1"
  vm_static_ip         = "192.168.50.16/24"
  network_device_model = "virtio"

  tags = ["vm", "dev", "docker"]

  ssh_public_key_content = local.ssh_public_key_content
}
```

## Network Configuration

All VMs are connected to bridge `vmbr0` for LAN access.

| VM Name         | VM ID | Static IP        | Purpose                 |
| --------------- | ----- | ---------------- | ----------------------- |
| ubuntu-template | 901   | N/A              | Template (off)          |
| dev-docker-02   | 101   | 192.168.50.16/24 | Development Docker host |

**Gateway:** 192.168.50.1
**DNS:** Configured via cloud-init / DHCP

## SSH Access

All VMs are accessible via SSH using the injected public key:

```bash
# Access dev-docker-02
ssh ka8kgj@192.168.50.16
```

## Working with This Environment

### Prerequisites

- **HCP Terraform Token:** Run `terraform login` to authenticate with HCP Terraform (`app.terraform.io`) for remote state in the `proxmox-pve-d01` workspace. The token is stored locally in `~/.terraform.d/credentials.tfrc.json`.
- **Not Stored in Infisical:** **The Terraform Cloud user API token is NOT stored in Infisical.** It must be generated and maintained on your local workstation via `terraform login`.
- **Infisical Secrets:** Universal Auth credentials configured in `.env` (`INFISICAL_CLIENT_ID`, `INFISICAL_CLIENT_SECRET`, `INFISICAL_PROJECT_ID`). Proxmox host connection secrets (`PVE_ENDPOINT`, `PVE_TOKEN`) are stored in and dynamically retrieved from the Infisical vault at `/terraform/proxmox/pve-d01`.

All operations should be executed via the repository root Makefile:

### Initialize

```bash
make init TARGET=proxmox/pve-d01
```

### Plan Changes

```bash
make plan TARGET=proxmox/pve-d01
```

### Apply Configuration

```bash
make apply TARGET=proxmox/pve-d01
```

## Important Notes

- **VM IDs:** Uses 9xx for templates and 1xx for VMs
- **Storage:** Uses `local-zfs` storage pool for OS disks and EFI disks
- **BIOS:** OVMF (EFI) boot on Q35 machine type
- **Start on Boot:** Controlled by `vm_on_boot` (set to `false` for development VMs)

## See Also

- [Proxmox Modules Documentation](../../../modules/proxmox/)
- [Main Proxmox Environments README](../README.md)
- [Main Terraform README](../../README.md)
