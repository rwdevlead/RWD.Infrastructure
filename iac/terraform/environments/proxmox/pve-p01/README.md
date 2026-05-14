# Proxmox Production Environment - Terraform

This directory contains the Terraform configuration for the production Proxmox cluster.

## Environment Overview

- **Proxmox Node:** `pve-p01`
- **Purpose:** Production infrastructure and services
- **Infrastructure:** Production Docker host, TrueNAS storage, and Ubuntu templates
- **Network:** 192.168.50.0/24
- **Criticality:** High - contains production workloads

## Virtual Machines

### Templates

#### ubuntu-2404-template (VM ID: 801)

Ubuntu 24.04 LTS template for cloning production VMs.

- **Status:** Powered off (template mode)
- **Hardware:** 2 CPU cores, 4096 MB RAM, 20 GB disk
- **Boot:** EFI (OVMF), UEFI firmware
- **OS:** Ubuntu 24.04 (cloud-images)
- **SSH:** Public key injection via cloud-init
- **ISO Source:** Ubuntu cloud images

**Note:** Regularly updated and maintained for security and stability.

### VMs

#### prod-docker-01 (VM ID: 101)

Production Docker host for running containerized services.

- **Status:** Running
- **Hardware:** 2 CPU cores, 4-8 GB RAM (dynamic), 40 GB disk
- **Network:** Static IP `192.168.50.14/24`
- **OS:** Ubuntu 24.04 (cloned from template)
- **User:** ka8kgj
- **Services:** Docker, Docker Compose, Traefik reverse proxy
- **Use Case:** Production containerized applications

#### truenas (VM ID: 500)

TrueNAS SCALE storage appliance for NFS and SMB storage.

- **Hardware:** Custom (CPU, RAM, disk via Terraform)
- **Boot Disk:** 32 GB
- **Data Disk:** Physical disk via passthrough
- **Network:** Static IP (manual via Web UI)
- **Use Case:** Network storage, backups, NFS exports
- **Management:** Web UI at https://192.168.50.13:6000 (approx)

## Configuration Structure

```hcl
# SSH Key Management
locals {
  ssh_public_key_content  = trimspace(file("~/.ssh/id_ed25519.pub"))
  ssh_private_key_content = file("~/.ssh/id_ed25519")
}

# Ubuntu Template
module "ubuntu_template" {
  source = "../../../modules/proxmox/template-ubuntu"

  vm_id         = 801
  vm_name       = "ubuntu-2404-template"
  node_name     = "pve-p01"
  template_mode = true  # Production template (always in template mode)

  # Configuration...
}

# Production Docker VM
module "Prod_Docker_01" {
  source = "../../../modules/proxmox/clone-vm"

  tempate_node_id   = module.ubuntu_template.template_id
  tempate_node_name = module.ubuntu_template.template_node_name

  vm_id        = 101
  vm_name      = "prod-docker-01"
  vm_node_name = "pve-p01"
  vm_static_ip = "192.168.50.14/24"

  # Configuration...
}
```

## Network Configuration

All VMs are connected to bridge `vmbr0` for LAN access.

| VM Name         | IP Address       | Purpose           |
| --------------- | ---------------- | ----------------- |
| ubuntu-template | N/A              | Template (off)    |
| prod-docker-01  | 192.168.50.14/24 | Production Docker |
| truenas         | 192.168.50.13/24 | NFS/SMB Storage   |

**Gateway:** 192.168.50.1
**DNS:** Configured via DHCP/Manual

## SSH Access

Production VMs are accessible via SSH:

```bash
# Access production Docker host
ssh ka8kgj@192.168.50.14

# Access via hostname (if DNS configured)
ssh ka8kgj@prod-docker-01.local
```

## Storage Architecture

### Boot Storage

- **Location:** `local-lvm` on Proxmox host
- **Size:** 40 GB per Docker VM
- **IOPS:** Standard SSD speeds

### Data Storage

- **Type:** TrueNAS NFS storage
- **Location:** 192.168.50.13
- **Mount Points:**
  - `/mnt/docker/` - Docker volumes and data
  - `/mnt/backups/` - Backup storage
- **Redundancy:** ZFS with replication (managed via Ansible)

## Template Management

### Updating Production Template

Production templates are kept in `template_mode = true` and rarely modified:

1. Create new template with updated OS
2. Test thoroughly in development environment
3. Migrate prod-docker-01 to new template
4. Archive old template

### Template Creation Workflow

If needing to create a new production template:

1. Temporarily set `template_mode = false`
2. Apply and let cloud-init run
3. Run security updates: `sudo apt update && sudo apt upgrade`
4. Run cleanup: `make cleanup-vm`
5. Convert to template: `make convert-to-template`
6. Set `template_mode = true`
7. Apply again to seal template

## Production Considerations

### High Availability

- Single Docker host (consider redundancy for critical services)
- NFS storage for persistent data
- Regular backups via Ansible

### Security

- SSH key-based authentication only
- Security group (firewall) rules configured per service
- Traefik reverse proxy for HTTPS termination

### Monitoring

Services are monitored via:

- Docker health checks
- Ansible health verification
- Traefik endpoint monitoring

### Backup Strategy

- Regular backups to TrueNAS
- Database dumps for stateful services
- Configuration version control via Git

## Working with This Environment

### Prerequisites

1. **Proxmox API Token** (high privilege)
   - Create in Proxmox UI: Datacenter > Permissions > API Tokens
   - Requires full VM management permissions

2. **Environment Variables**

   ```bash
   export PROXMOX_VE_ENDPOINT="https://pve-p01.example.com:8006"
   export PROXMOX_VE_API_TOKEN="user@pam!terraform=<token>"
   export PROXMOX_VE_INSECURE=true
   ```

3. **SSH Keys** (ED25519 for security)
   - Public key: `~/.ssh/id_ed25519.pub`
   - Private key: `~/.ssh/id_ed25519`

4. **Access Control**
   - Only authorized administrators
   - Review all changes via `terraform plan` before applying

### Initialize

```bash
terraform init
```

### Plan Changes (Always Required!)

```bash
terraform plan
# Review output carefully before applying
```

### Apply Configuration

```bash
# Only after thorough review of plan
terraform apply
```

### Emergency Procedures

For critical issues:

1. Check Proxmox console directly
2. Review Terraform state: `terraform show`
3. Use `terraform refresh` to update state from actual infrastructure

## Common Production Tasks

### Scaling Docker Host

To increase Docker VM resources:

1. Edit `vm_cores`, `vm_memory_min`, `vm_memory_max` in `main.tf`
2. Plan and review changes: `terraform plan`
3. Apply during maintenance window: `terraform apply`
4. Restart services as needed

### Adding Storage

To add storage to VMs:

1. Increase `disk_size` in module
2. Plan and apply
3. Extend filesystem from VM: `sudo growpart /dev/vda 1 && sudo resize2fs /dev/vda1`

### Updating VM Configuration

1. Modify module parameters in `main.tf`
2. Run `terraform plan` to preview
3. Apply during approved maintenance window
4. Verify services are healthy post-update

## Disaster Recovery

### State Recovery

If state file is corrupted:

1. Backup current state: `cp terraform.tfstate terraform.tfstate.backup`
2. Run refresh: `terraform refresh`
3. Compare with backup: `diff terraform.tfstate terraform.tfstate.backup`

### VM Recovery

If a VM is accidentally deleted:

1. Restore from backup
2. Or re-apply Terraform: `terraform apply`
3. Restore data from NFS backups

## Important Notes

- **VM IDs:** Production uses 8xx for templates, 1xx-2xx for VMs
- **No Testing:** This is production - test all changes in dev first
- **Storage:** Uses `local-lvm` for boot disks, NFS for data
- **Backups:** Critical for disaster recovery
- **Change Management:** All changes require review and approval
- **Maintenance Windows:** Plan during approved maintenance periods

## Troubleshooting

### VM Not Responding

1. Check Proxmox console
2. Verify network connectivity: `ping 192.168.50.14`
3. Check Terraform state: `terraform show`

### Storage Issues

1. Check TrueNAS Web UI
2. Verify NFS mount: `sudo mount | grep nfs`
3. Check disk space: `df -h`

### SSH Access Issues

1. Verify SSH key permissions: `chmod 600 ~/.ssh/id_ed25519`
2. Check VM SSH service: `ssh -v`
3. Review Proxmox firewall rules

## See Also

- [Proxmox Modules Documentation](../../../modules/proxmox/)
- [Main Proxmox Environment README](../README.md)
- [Main Terraform README](../README.md)
- [Infrastructure README](../../../README.md)
