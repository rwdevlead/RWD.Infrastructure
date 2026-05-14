# Terraform Infrastructure

This directory contains Terraform configurations for managing infrastructure across multiple platforms using infrastructure-as-code principles.

## Overview

Terraform configurations are organized into two main categories:

1. **[Modules](./modules/)** - Reusable infrastructure components
2. **[Environments](./environments/)** - Environment-specific root module configurations

### Supported Platforms

- **GitHub** - Organization and repository management
- **Proxmox VE** - Virtual machine provisioning and management

## Directory Structure

```
terraform/
├── README.md                              # This file
├── modules/
│   ├── README.md                          # Module overview
│   ├── github/
│   │   ├── README.md
│   │   ├── github-repository/             # Repository management
│   │   ├── github-teams/                  # Team management
│   │   ├── github-branch-protection/      # Branch protection rules
│   │   └── github-codeowners/             # CODEOWNERS file management
│   └── proxmox/
│       ├── README.md
│       ├── template-ubuntu/               # Ubuntu template creation
│       ├── clone-vm/                      # VM cloning from templates
│       ├── homeassistant/                 # Home Assistant VM provisioning
│       └── truenas-vm/                    # TrueNAS storage VM
└── environments/
    ├── README.md                          # Environment overview
    ├── github/
    │   ├── README.md                      # GitHub environments
    │   ├── realworlddevelopers/           # Real World Developers org
    │   └── rwdevlead/                     # RWD Leadership org
    └── proxmox/
        ├── README.md                      # Proxmox environments
        ├── proxmox/                       # Dev/test cluster
        └── pve-p01/                       # Production cluster
```

## Modules

Reusable infrastructure components are located in [./modules/](./modules/):

### GitHub Modules

- **[github-repository](./modules/github/github-repository/)** - Creates and configures GitHub repositories
- **[github-teams](./modules/github/github-teams/)** - Manages GitHub teams and members
- **[github-branch-protection](./modules/github/github-branch-protection/)** - Configures branch protection rules
- **[github-codeowners](./modules/github/github-codeowners/)** - Manages CODEOWNERS files

### Proxmox Modules

- **[template-ubuntu](./modules/proxmox/template-ubuntu/)** - Creates Ubuntu VM templates
- **[clone-vm](./modules/proxmox/clone-vm/)** - Clones VMs from templates
- **[homeassistant](./modules/proxmox/homeassistant/)** - Home Assistant VM provisioning
- **[truenas-vm](./modules/proxmox/truenas-vm/)** - TrueNAS SCALE appliance provisioning

See [modules/README.md](./modules/README.md) for detailed module documentation.

## Environments

Environment-specific configurations are located in [./environments/](./environments/):

Each environment is a complete Terraform root module that can be initialized and applied independently.

### GitHub Environments

- **[realworlddevelopers/](./environments/github/realworlddevelopers/)** - Real World Developers organization (multiple repositories and teams)
- **[rwdevlead/](./environments/github/rwdevlead/)** - RWD Leadership organization (infrastructure and governance)

### Proxmox Environments

- **[proxmox/](./environments/proxmox/proxmox/)** - Development/test cluster (template development, testing)
- **[pve-p01/](./environments/proxmox/pve-p01/)** - Production cluster (production workloads, storage)

See [environments/README.md](./environments/README.md) for environment-specific details.

## Working with Terraform

### Project Root vs Environment Directory

```
# From project root - specify target
make init TARGET=github/realworlddevelopers
make plan TARGET=github/realworlddevelopers
make apply TARGET=github/realworlddevelopers

# Or work directly in environment directory
cd environments/github/realworlddevelopers
terraform init
terraform plan
terraform apply
```

### State Management

- Each root module (environment) has its own state file
- State files are **gitignored** for security (they contain sensitive data)
- State files are stored locally: `environments/*/*/terraform.tfstate`
- Never commit state files to version control

### Common Workflows

#### Planning Changes

1. Modify configuration in target environment
2. Run `terraform plan` to preview changes
3. Review output carefully
4. Run `terraform apply` when ready

#### Importing Existing Infrastructure

```bash
cd environments/github/realworlddevelopers
terraform import 'module.rwd_graphics.github_repository.this' 'rwd-graphics'
```

#### Formatting and Validation

```bash
# From project root
make fmt TARGET=<target>
make validate TARGET=<target>
```

## Proxmox Template Creation Workflow

Creating VM templates in Proxmox involves a two-step process using Terraform, shell scripts, and manual conversion.

### Step 1: Initial VM Creation

```hcl
module "ubuntu_template" {
  source = "../../../modules/proxmox/template-ubuntu"

  vm_id         = 901
  template_mode = false    # Create as normal VM initially
  vm_startup    = false

  # Other configuration...
}
```

1. Set `template_mode = false`
2. Run `terraform apply`
3. VM boots and cloud-init runs

### Step 2: Cleanup and Sealing

From the project root:

```bash
# Run cleanup tasks (installs tools, clears logs, etc.)
make cleanup-vm

# Run template conversion script
make convert-to-template
```

These scripts:

- Clear system logs
- Remove SSH host keys
- Clear machine-id for unique IDs on clones
- Prepare VM for template use

### Step 3: Template Conversion

```hcl
module "ubuntu_template" {
  source = "../../../modules/proxmox/template-ubuntu"

  vm_id         = 901
  template_mode = true     # Convert to template
  vm_startup    = false

  # Other configuration unchanged...
}
```

1. Update `template_mode = true`
2. Run `terraform apply`
3. Terraform stops the VM and converts it to a template

### Cloning from Template

Once template is ready, create VMs by cloning:

```hcl
module "dev_docker" {
  source = "../../../modules/proxmox/clone-vm"

  tempate_node_id   = module.ubuntu_template.template_id
  tempate_node_name = module.ubuntu_template.template_node_name

  vm_id        = 201
  vm_name      = "dev-docker-01"
  vm_node_name = "proxmox"

  # Clone-specific configuration...
}
```

## Important Notes

### Ubuntu Cloud Images

- Ubuntu templates are created from official cloud images
- No QEMU guest agent pre-installed in images
- Guest agent is installed during cloud-init for IP retrieval
- IP addresses may not be immediately available after VM startup

### Template Cleanup Scripts

Critical operations performed during template sealing:

- `truncate -s 0 /etc/machine-id` - Clears machine ID for unique clones
- SSH host key removal - Ensures each clone has unique SSH keys
- Log clearing - Removes deployment history
- **After these operations, VM must be shut down immediately** to preserve sealed state

### Proxmox VM IDs

Standard VM ID allocation:

- **8xx series** - Production templates (801+)
- **9xx series** - Development templates (901+)
- **1xx series** - Production instances (101+)
- **2xx series** - Development instances (201+)
- **5xx series** - Special VMs (storage, services) (500+)

## Best Practices

1. **Always Plan First** - Use `terraform plan` to review changes before applying
2. **State Files** - Keep state files secure and synchronized with team
3. **Variable Separation** - Use separate `.tfvars` files for sensitive data
4. **Documentation** - Keep this README and module READMEs updated
5. **Testing** - Test infrastructure changes in dev environment first
6. **Backup** - Regularly backup state files
7. **Version Control** - Only commit `.tf` files, not state files or sensitive variables

## Troubleshooting

### State Lock

If Terraform is stuck on a state lock:

```bash
# View lock info
cat environments/*/*/terraform.tfstate.lock.info

# Unlock (use with caution!)
terraform force-unlock <LOCK_ID>
```

### Provider Issues

```bash
# Reinitialize provider plugins
rm -rf .terraform
terraform init
```

### State Drift

```bash
# Refresh state from actual infrastructure
terraform refresh

# See current state
terraform show
```

## See Also

- [Modules Documentation](./modules/README.md)
- [Environments Documentation](./environments/README.md)
- [GitHub Modules](./modules/github/README.md)
- [Proxmox Modules](./modules/proxmox/README.md)
- [GitHub Terraform Provider](https://registry.terraform.io/providers/integrations/github/latest/docs)
- [Proxmox Terraform Provider](https://registry.terraform.io/providers/bpg/proxmox/latest/docs)
