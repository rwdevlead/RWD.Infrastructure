# Proxmox Terraform Environments

This directory contains environment-specific configurations for managing Proxmox Virtual Environments.

## Proxmox Cluster Environments

### [proxmox/](./proxmox/)

Development/Test Proxmox cluster configuration.

**Node:** `proxmox`
**Environment:** Development and testing
**Primary VMs:**

- Ubuntu templates (VM ID 901+)
- Development Docker instances (VM ID 201+)
- Home Assistant instance (VM ID 102)

**Use Case:**

- Template development and testing
- VM cloning testing
- Development workloads

---

### [pve-p01/](./pve-p01/)

Production Proxmox environment configuration.

**Node:** `pve-p01`
**Environment:** Production
**Primary VMs:**

- Ubuntu templates (VM ID 801+)
- Production Docker instances (VM ID 101+)
- TrueNAS storage VM

**Use Case:**

- Production infrastructure
- Critical services
- Persistent storage

---

## Common Configuration Pattern

Both environments follow a standard workflow for VM provisioning:

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

  vm_static_ip = "192.168.50.14/24"
  vm_cores     = 2
  vm_memory_min = 4096
  vm_memory_max = 8192
  disk_size    = 40

  ssh_public_key_content = local.ssh_public_key_content
}
```

### 3. Specialized Configurations

Special-purpose VMs like Home Assistant and TrueNAS use dedicated modules:

```hcl
module "homeassistant" {
  source = "../../modules/proxmox/homeassistant"

  vm_id         = 102
  vm_name       = "homeassistant"
  node_name     = "proxmox"

  vm_cores      = 2
  vm_memory     = 4096
  disk_size     = 32
}

module "truenas" {
  source = "../../modules/proxmox/truenas-vm"

  vm_id        = 500
  data_disk_id = "ata-ST4000DM004-2CX173_ZDH0EYT0"
}
```

## SSH Key Management

Both environments use SSH keys for cloud-init configuration:

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

### Production Environment (pve-p01)

| VM Name         | VM ID | Static IP        | Purpose                |
| --------------- | ----- | ---------------- | ---------------------- |
| ubuntu-template | 801   | N/A              | Template (not running) |
| prod-docker-01  | 101   | 192.168.50.14/24 | Production Docker host |
| truenas         | 500   | Manual           | NFS/Storage server     |

## Template Creation Workflow

See the [main Terraform README](../README.md#creating-templates-in-proxmox) for detailed template creation steps including:

1. Setting `template_mode = false` for initial creation
2. Running cleanup scripts
3. Converting to template with `template_mode = true`

## Working with Proxmox Environments

### Prerequisites

1. **Proxmox API Token**
   - Create in Proxmox UI: Datacenter > Permissions > API Tokens
   - Set environment variables:
     - `PROXMOX_VE_ENDPOINT` - Proxmox API endpoint
     - `PROXMOX_VE_API_TOKEN` - API token value
     - `PROXMOX_VE_INSECURE` - true if using self-signed certificates

2. **SSH Keys**
   - Public key for cloud-init: `~/.ssh/id_ed25519.pub`
   - Private key for Terraform connections: `~/.ssh/id_ed25519`

3. **Network Access**
   - Terraform must be able to reach Proxmox API
   - SSH access to Proxmox host for remote-exec operations

### Initialize Environment

```bash
export PROXMOX_VE_ENDPOINT="https://proxmox.example.com:8006"
export PROXMOX_VE_API_TOKEN="user@pam!terraform=<token-value>"
export PROXMOX_VE_INSECURE=true

cd environments/proxmox/pve-p01
terraform init
```

### Preview Changes

```bash
terraform plan
```

### Apply Configuration

```bash
terraform apply
```

## State Management

Each Proxmox environment maintains separate state:

- `environments/proxmox/proxmox/terraform.tfstate` - Dev/test infrastructure
- `environments/proxmox/pve-p01/terraform.tfstate` - Production infrastructure

**Important:** These files contain sensitive information and are gitignored.

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
