# Proxmox Terraform Environments

This directory contains environment-specific configurations for managing Proxmox Virtual Environments.

## Proxmox Cluster Environments

### [proxmox/](./proxmox/)

Development/Test Proxmox cluster configuration.

**Node:** `proxmox`
**Environment:** Development and testing
**Primary VMs:**

- Ubuntu templates (VM ID 901+)
- Development Docker instances (`dev-docker-01`, VM ID 201)
- Home Assistant instance (VM ID 102)
- TrueNAS storage VM (`dev-truenas-01`, VM ID 200)

**Use Case:**

- Template development and testing
- VM cloning testing
- Development workloads and network storage

---

### [pve-d01/](./pve-d01/)

Development standalone Proxmox environment configuration.

**Node:** `pve-d01`
**Environment:** Development staging
**Storage:** `local-zfs`
**Primary VMs:**

- Ubuntu templates (VM ID 901+)
- Development Docker instances (`dev-docker-02`, VM ID 101)

**Use Case:**

- Staging containerized services
- Secondary development workloads

---

### [pve-p01/](./pve-p01/)

Production Proxmox environment configuration.

**Node:** `pve-p01`
**Environment:** Production
**Primary VMs:**

- Ubuntu templates (VM ID 801+)
- Production Docker instances (`prod-docker-01`, VM ID 101)
- OpenMediaVault storage VM (`dev-omv-01`, VM ID 102)

**Use Case:**

- Production infrastructure
- Critical services
- Persistent storage

---

## Common Configuration Pattern

All environments follow a standard workflow for VM provisioning:

### 1. Template Creation

```hcl
module "ubuntu_template" {
  source = "../../modules/proxmox/template-ubuntu"

  vm_id   = 901         # dev, 801 = prod
  vm_name = "ubuntu-2404-template"
  node_name = "proxmox"  # dev, "pve-p01" = prod

  template_mode = false  # Initially create as normal VM
  vm_startup    = false

  disk_size     = 20
  iso_url       = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"

  ssh_public_key_content = local.ssh_public_key_content
}
```

**Workflow:**

1. Set `template_mode = false` and apply
2. Run cleanup and conversion scripts
3. Change `template_mode = true` and apply again

### 2. VM Cloning from Template

```hcl
module "production_docker" {
  source = "../../modules/proxmox/clone-vm"

  tempate_node_id   = module.ubuntu_template.template_id
  tempate_node_name = module.ubuntu_template.template_node_name

  vm_id        = 101
  vm_name      = "prod-docker-01"
  vm_node_name = "pve-p01"
  vm_on_boot   = false

  vm_static_ip = "192.168.50.14/24"
  vm_cores     = 2
  vm_memory_min = 4096
  vm_memory_max = 8192
  disk_size    = 40

  ssh_public_key_content = local.ssh_public_key_content
}
```

### 3. Specialized Configurations

Special-purpose VMs like Home Assistant, TrueNAS, and OpenMediaVault use dedicated modules:

```hcl
module "homeassistant" {
  source = "../../modules/proxmox/homeassistant"

  vm_id          = 102
  vm_name        = "homeassistant"
  vm_description = "Home Assistant Instance"
  vm_on_boot     = false
  node_name      = "proxmox"

  vm_cores  = 2
  vm_memory = 4096
  disk_size = 32
}

module "truenas" {
  source            = "../../modules/proxmox/truenas-vm"
  vm_name           = "dev-truenas-01"
  vm_id             = 200
  vm_on_boot        = false
  proxmox_node_name = "proxmox"
  proxmox_node_ip   = "192.168.50.11"
  data_disk_id      = "ata-ST1000DM003-1ER162_Z4YCRN9L"
}

module "omv_vm" {
  source            = "../../modules/proxmox/omv-vm"
  vm_name           = "dev-omv-01"
  vm_id             = 102
  vm_on_boot        = false
  proxmox_node_name = "pve-p01"
  proxmox_node_ip   = "192.168.50.10"
  data_disk_id      = "ata-HGST_HTS541010A9E680_JA1009C033492P"
}
```

## SSH Key Management

All environments use SSH keys for cloud-init configuration:

```hcl
locals {
  ssh_public_key_content  = trimspace(file("~/.ssh/id_ed25519.pub"))
  ssh_private_key_content = file("~/.ssh/id_ed25519")
}
```

**Important:** Update the key paths if using different SSH keys for different environments.

## IP Address Allocation

### Development Environment (proxmox)

| VM Name         | VM ID | Static IP        | Purpose                 |
| --------------- | ----- | ---------------- | ----------------------- |
| ubuntu-template | 901   | N/A              | Template (not running)  |
| dev-docker-01   | 201   | 192.168.50.12/24 | Development Docker host |
| homeassistant   | 102   | Dynamic          | Home Assistant          |
| dev-truenas-01  | 200   | 192.168.50.13/24 | TrueNAS Storage         |

### Development Environment (pve-d01)

| VM Name         | VM ID | Static IP        | Purpose                 |
| --------------- | ----- | ---------------- | ----------------------- |
| ubuntu-template | 901   | N/A              | Template (not running)  |
| dev-docker-02   | 101   | 192.168.50.16/24 | Development Docker host |

### Production Environment (pve-p01)

| VM Name         | VM ID | Static IP        | Purpose                |
| --------------- | ----- | ---------------- | ---------------------- |
| ubuntu-template | 801   | N/A              | Template (not running) |
| prod-docker-01  | 101   | 192.168.50.14/24 | Production Docker host |
| dev-omv-01      | 102   | 192.168.50.17/24 | OpenMediaVault Storage |

## Template Creation Workflow

See the [main Terraform README](../README.md#creating-templates-in-proxmox) for detailed template creation steps including:

1. Setting `template_mode = false` for initial creation
2. Running cleanup scripts
3. Converting to template with `template_mode = true`

## Working with Proxmox Environments

### Prerequisites

1. **HCP Terraform Token**
   - Run `terraform login` to authenticate with HCP Terraform (`app.terraform.io`).
   - Token is saved locally in `~/.terraform.d/credentials.tfrc.json`.
   - **Important:** **The Terraform Cloud API token is NOT stored in Infisical.** It must be generated and managed directly on your local workstation via `terraform login`.

2. **Infisical Secrets**
   - Universal Auth credentials configured in `.env` (`INFISICAL_CLIENT_ID`, `INFISICAL_CLIENT_SECRET`, `INFISICAL_PROJECT_ID`).
   - Proxmox host connection secrets (`PVE_ENDPOINT`, `PVE_TOKEN`) are stored in and dynamically retrieved from the Infisical vault under `/terraform/proxmox/<environment>`.

3. **SSH Keys**
   - Public key for cloud-init: `~/.ssh/id_ed25519.pub`
   - Private key for Terraform host connections: `~/.ssh/id_ed25519`

### Operations via Makefile

All actions should be executed via the repository root Makefile:

```bash
# Initialize target environment
make init TARGET=proxmox/pve-p01

# Preview planned changes
make plan TARGET=proxmox/pve-p01

# Apply changes
make apply TARGET=proxmox/pve-p01
```

## State Management

All Proxmox environments maintain remote state in **HCP Terraform (Terraform Cloud)** under organization `realworlddevelopers` and project `RWD Infrastructure`:

- `environments/proxmox/proxmox` -> Workspace: `proxmox-legacy`
- `environments/proxmox/pve-d01` -> Workspace: `proxmox-pve-d01`
- `environments/proxmox/pve-p01` -> Workspace: `proxmox-pve-p01`

## Important Notes

- **VM IDs:** Use 9xx series for templates (dev) and 8xx (prod), 1xx-2xx for instances
- **Storage:** Most environments use `local-lvm` storage pool
- **Networking:** Bridge adapter `vmbr0` for VM networking
- **Host Keys:** SSH host keys must be accepted before Terraform can connect
- **Remote Execution:** Disk passthrough uses remote-exec for `qm set` commands

## See Also

- [Proxmox Modules](../../modules/proxmox/)
- [Proxmox Terraform Provider](https://registry.terraform.io/providers/bpg/proxmox/latest/docs)
- [Main Terraform README](../README.md)
