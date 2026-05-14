# Proxmox Terraform Modules

This directory contains modules for provisioning and managing virtual machines on Proxmox Virtual Environment.

## Modules

### [template-ubuntu](./template-ubuntu/)

Creates Ubuntu VM templates on Proxmox using cloud-init for initial configuration.

**Features:**

- Ubuntu cloud image provisioning
- Cloud-init configuration
- EFI boot support
- Configurable hardware (CPU, RAM, disk)
- SSH key injection for secure access
- Template or VM mode
- Customizable startup behavior

**Key Variables:**

- `vm_id` - Unique Proxmox VM ID
- `vm_name` - Name of the VM template
- `node_name` - Proxmox node where the template is created
- `template_mode` - Whether to convert to template (default: true)
- `vm_startup` - Auto-start VM on Proxmox boot
- `vm_cores`, `vm_memory`, `disk_size` - Hardware specifications
- `iso_url` - URL to Ubuntu cloud image
- `ssh_public_key_content` - SSH public key for cloud-init

**Outputs:**

- `template_id` - The template VM ID
- `template_node_name` - Proxmox node name

**Notes:**

- Create templates without the QEMU guest agent installed
- Use in combination with [clone-vm](#clone-vm) for VM provisioning
- See main Terraform README for template creation workflow

---

### [clone-vm](./clone-vm/)

Clones virtual machines from existing templates on Proxmox.

**Features:**

- VM cloning from templates
- Static IP configuration
- Cloud-init customization
- Hardware configuration (CPU, RAM, disk)
- SSH key injection
- Automatic VM startup

**Key Variables:**

- `tempate_node_id` - Template VM ID
- `tempate_node_name` - Proxmox node of template
- `vm_id` - Unique ID for the new VM
- `vm_name` - Name of the cloned VM
- `vm_node_name` - Proxmox node for new VM
- `vm_static_ip` - Static IP configuration (CIDR format)
- `vm_cores`, `vm_memory_min`, `vm_memory_max` - Hardware specs
- `vm_username`, `vm_password` - VM credentials
- `disk_size` - Cloned disk size in GB

**Outputs:**

- `vm_ipv4_address` - The assigned IPv4 address (or status if not assigned)

**Notes:**

- Requires guest agent for IP address retrieval
- VM is powered off until explicitly started
- IP assignment depends on cloud-init and DHCP/static configuration

---

### [homeassistant](./homeassistant/)

Provisions Home Assistant virtual machines on Proxmox.

**Features:**

- Specialized Home Assistant VM provisioning
- Cloud-init based setup
- Pre-configured for typical HA requirements
- IP address retrieval support

**Key Variables:**

- `vm_id` - Unique VM ID
- `vm_name` - VM name
- `node_name` - Proxmox node
- `vm_cores`, `vm_memory`, `disk_size` - Hardware configuration
- `vm_description` - VM description

**Outputs:**

- `vm_id` - The Home Assistant VM ID
- `vm_name` - The VM name

**Notes:**

- Built on template-based cloning
- IP address output commented out (requires guest agent)
- Consider adding health checks for production use

---

### [truenas-vm](./truenas-vm/)

Provisions the hardware "shell" for a TrueNAS SCALE appliance on Proxmox.

**Scope:**

- **Terraform:** Manages CPU, RAM, Boot Disk, and Physical Disk Passthrough
- **Manual:** OS Installation via ISO and initial Network/SSL setup via Web UI
- **Ansible:** Manages ZFS Pools, Datasets, and SMB/NFS Shares

**Features:**

- Physical disk passthrough via `qm set` remote execution
- Boot disk configuration
- Customizable hardware

**Key Variables:**

- `vm_id` - Unique Proxmox VM ID
- `data_disk_id` - Physical drive ID (e.g., `ata-ST1000...`)
- `boot_datastore` - Proxmox storage for OS

**Provisioning Workflow:**

1. **Terraform:** Creates VM shell and handles physical disk passthrough
2. **Manual:** OS installation and Web UI network/SSL setup
3. **DNS:** Map `truenas.local.rwdevs.com` to the static IP
4. **Ansible:** Configure ZFS pools, datasets, and shares

**Networking Note:**

- Does not inject networking via Cloud-Init to avoid conflicts with TrueNAS database
- Static IPs must be set manually in the TrueNAS UI

**Important Notes:**

- Disk passthrough uses `null_resource` with `remote-exec` to run `qm set` directly
- After `terraform apply`, complete TrueNAS installation manually via Proxmox console
- Set static IP and SSL certificates in TrueNAS Web UI to ensure they're saved to internal config

---

## Common Usage Patterns

### Creating and Cloning VMs

```hcl
# Step 1: Create Ubuntu template
module "ubuntu_template" {
  source = "./modules/proxmox/template-ubuntu"

  vm_id      = 901
  vm_name    = "ubuntu-2404-template"
  node_name  = "proxmox"

  template_mode = false  # Initially create as normal VM
  vm_startup    = false

  disk_size              = 20
  iso_url               = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
  iso_checksum          = "d8f7f427a53c221feee90d47ca008d89237e206a2d4935c98b84eefdbf52f41d"

  ssh_public_key_content = file("~/.ssh/id_ed25519.pub")
}

# Step 2: Clone VM from template
module "dev_docker" {
  source = "./modules/proxmox/clone-vm"

  tempate_node_id   = module.ubuntu_template.template_id
  tempate_node_name = module.ubuntu_template.template_node_name

  vm_id        = 201
  vm_name      = "dev-docker-01"
  vm_node_name = "proxmox"

  vm_static_ip = "192.168.50.12/24"
  vm_cores     = 2
  vm_memory_min = 4096
  vm_memory_max = 8192
  disk_size    = 40

  ssh_public_key_content = file("~/.ssh/id_ed25519.pub")
}
```

### Template Conversion Workflow

See the main [Terraform README](../README.md#creating-templates-in-proxmox) for the complete template creation and conversion workflow.

## Environment Configuration

See [../environments/proxmox/](../environments/proxmox/) for environment-specific configurations.
