# Terraform Infrastructure

This repository contains Terraform configurations for managing infrastructure across multiple platforms:

- **GitHub**: Repository management, teams, branch protection, and CODEOWNERS files
- **Proxmox**: Virtual machine provisioning, cloning, and template creation

## Modules

### GitHub Modules

- [GitHub Repository](./github/modules/github-repository/README.md) - Creates and manages GitHub repositories
- [GitHub Teams](./github/modules/github-teams/README.md) - Manages GitHub teams and memberships
- [GitHub Branch Protection](./github/modules/github-branch-protection/README.md) - Configures branch protection rules
- [GitHub CODEOWNERS](./github/modules/github-codeowners/README.md) - Manages CODEOWNERS files for repositories

### Proxmox Modules

- [Clone VM](./proxmox/modules/clone-vm/README.md) - Clones virtual machines from templates
- [Home Assistant](./proxmox/modules/homeassistant/README.md) - Provisions Home Assistant virtual machines
- [Ubuntu Template](./proxmox/modules/template-ubuntu/README.md) - Creates Ubuntu VM templates

## Important Notes

### Ubuntu Template Changes

**Note**: Ubuntu templates no longer have the QEMU guest agent installed with the IMG file. This is a recent change that affects VM cloning and IP address retrieval.

### Creating Templates in Proxmox

If you want to keep the template creation process within Terraform:

1. **Step A (The Build)**:

   - Set `template = false` and `started = true`
   - Run `terraform apply`
   - Result: The VM boots, Cloud-Init runs, installs tools, and executes cleanup/sealing commands

2. **Step B (The Seal)**:
   - Change to `template = true` and `started = false`
   - Run `terraform apply` again
   - Result: Terraform stops the VM and converts it to a template

### Warning on Cleanup Scripts

If your `runcmd` includes `truncate -s 0 /etc/machine-id`, the VM will be "broken" until reboot (as the machine-id is cleared). This is ideal for templates, which is why Step B (immediate shutdown after script execution) is critical.
