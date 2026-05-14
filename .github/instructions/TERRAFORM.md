# Terraform (HCL) Instructions

## Overview

Terraform is used for Infrastructure as Code with two primary targets:

- **GitHub**: Repository, team, and branch protection configuration
- **Proxmox**: Virtual machine provisioning and management

## Project Structure

The Terraform directory is organized into **modules** (reusable components) and **environments** (root modules that use those modules):

```
iac/terraform/
├── modules/                      # Reusable infrastructure components
│   ├── github/                   # GitHub management modules
│   │   ├── github-repository/    # Repository creation and management
│   │   ├── github-teams/         # Team management
│   │   ├── github-branch-protection/  # Branch protection rules
│   │   └── github-codeowners/    # CODEOWNERS file management
│   └── proxmox/                  # Proxmox VM provisioning modules
│       ├── template-ubuntu/      # Ubuntu VM template creation
│       ├── clone-vm/             # VM cloning from templates
│       ├── homeassistant/        # Home Assistant VM provisioning
│       └── truenas-vm/           # TrueNAS storage VM provisioning
│
└── environments/                 # Root module configurations (per environment)
    ├── github/                   # GitHub organization environments
    │   ├── realworlddevelopers/  # Real World Developers org
    │   └── rwdevlead/            # RWD Leadership org
    └── proxmox/                  # Proxmox cluster environments
        ├── proxmox/              # Development/test cluster
        └── pve-p01/              # Production cluster
```

## Root Modules vs Modules

### Modules (iac/terraform/modules/)

Reusable components that can be referenced by multiple root modules:

- Located in `modules/` directory
- Have `main.tf`, `variables.tf`, `outputs.tf`
- No provider configuration (inherited from parent)
- Referenced using relative paths: `source = "../../modules/github/github-repository"`

### Root Modules (iac/terraform/environments/)

Complete, ready-to-deploy configurations:

- Located in `environments/*/*/` (e.g., `environments/github/realworlddevelopers/`)
- Have their own state files
- Have their own provider configuration
- Can be initialized and applied independently

## File Organization

### Core Files

- **main.tf**: Resource and module definitions
- **variables.tf**: Input variables with descriptions and validation
- **outputs.tf**: Output values and exported data
- **providers.tf**: Provider configuration and authentication
- **.terraform/**: Local Terraform working directory (gitignored)
- **terraform.tfstate**: Current state file (gitignored)
- **terraform.tfstate.backup**: Previous state snapshot (gitignored)
- **tfplan**: Execution plan output (gitignored)
- **terraform.tfvars**: Variable values (gitignored - never commit)

### Module Structure

Follow [HashiCorp Module Structure](https://developer.hashicorp.com/terraform/language/modules/develop/structure):

```
module-name/
├── README.md         # Module documentation with usage examples
├── main.tf           # Primary resource definitions
├── variables.tf      # Input variable declarations
└── outputs.tf        # Output value declarations
```

## Development Workflow

### Before Committing

```bash
# Format all Terraform files recursively
terraform fmt -recursive

# Validate syntax in current directory
terraform validate

# Create execution plan (from environment directory)
cd environments/github/realworlddevelopers
terraform plan -out=tfplan
```

### Applying Changes

```bash
# Navigate to environment directory
cd environments/github/realworlddevelopers

# Review plan first
terraform plan

# Apply the changes
terraform apply
```

### Using with Make

From project root:

```bash
# Format code
make fmt TARGET=github/realworlddevelopers

# Validate configuration
make validate TARGET=github/realworlddevelopers

# Create plan for specific target
make plan TARGET=github/realworlddevelopers

# Apply changes
make apply TARGET=github/realworlddevelopers

# Plan for production environment
make plan TARGET=proxmox/pve-p01
```

## Naming Conventions

### Resources

- Use snake_case for resource names
- Be descriptive: `github_repository_my_app` not `github_repository_1`
- Follow pattern: `<type>_<scope>_<description>`

### Variables & Outputs

- Snake_case for all variable and output names
- Add descriptions to all variables
- Mark sensitive data with `sensitive = true`
- Use `validation` blocks for important constraints

### Modules

- Directory names with hyphens: `github-repository`, `clone-vm`
- Input variables use lowercase with underscores
- Follow [standard variable naming](https://developer.hashicorp.com/terraform/language/values/variables#variable-naming)

### Locals

- Use `locals` for computed values
- Group related locals together with comments
- Example:
  ```hcl
  locals {
    # Repository configuration
    repo_features = {
      has_issues      = true
      has_discussions = true
    }

    # Managed by information
    managed_by = "Managed by Terraform"
  }
  ```

## Best Practices

### Security

- Never hardcode secrets in `.tf` files
- Use `terraform.tfvars` for sensitive values (gitignored)
- Mark sensitive outputs with `sensitive = true`
- Use variable validation for security-critical inputs
- Keep state files secure (they contain sensitive data)

### State Management

- State files are gitignored - never commit them
- Each environment has its own state file
- Coordinate with team members to avoid state conflicts
- Backup state files before major changes
- Use state locking for team environments

### Code Organization

- Keep related resources in logical sections
- Use comments to separate sections
- One resource per `for_each` iteration (not multiple)
- Always provide descriptions for variables and outputs

### Modules

- Modules should be self-contained and reusable
- Every module must have a README.md
- Expose necessary variables, hide implementation details
- Use meaningful output names
- Test modules in isolation first

### Documentation

- Every `.tf` file should have comments explaining non-obvious logic
- Every module must have a README with:
  - Description and features
  - Usage examples
  - Input variables table
  - Output values table
  - Important notes and warnings

## Terraform Template Workflow

For Proxmox VMs, templates follow a specific multi-step workflow:

### Step 1: Create VM (template_mode=false)

Set `template_mode = false` and apply:

- VM is created and boots
- Cloud-init runs for initial setup
- VM is ready for sealing

### Step 2: Seal VM

Run cleanup scripts:

```bash
make cleanup-vm
make convert-to-template
```

These scripts clear:

- System logs
- SSH host keys
- Machine ID (for unique clones)
- Temporary files

### Step 3: Convert to Template (template_mode=true)

Update `template_mode = true` and apply:

- Terraform stops the VM
- VM is converted to a read-only template
- Template is ready for cloning

### Step 4: Clone from Template

Use the `clone-vm` module to create new VMs from the template:

```hcl
module "my_vm" {
  source = "../../modules/proxmox/clone-vm"

  tempate_node_id   = module.template.template_id
  tempate_node_name = module.template.template_node_name

  vm_id = 201
  # ... other configuration
}
```

## Common Tasks

### Initialize a New Environment

```bash
cd environments/github/realworlddevelopers
terraform init
```

### Add a New Module to Root Module

```hcl
module "my_resource" {
  source = "../../modules/github/github-repository"

  # Provide all required variables
  repository_name = "my-repo"
  description     = "My repository"
}
```

### Import Existing Resource

```bash
cd environments/github/realworlddevelopers
terraform import 'module.my_repo.github_repository.this' 'my-repo'
```

### View Current State

```bash
terraform show
terraform state list
terraform state show 'resource_type.resource_name'
```

### Destroy Resources (CAUTION!)

```bash
terraform destroy              # Destroy all
terraform destroy -target=resource_address  # Destroy specific resource
```

## Troubleshooting

### State Lock

If Terraform reports a state lock:

```bash
# View lock information
cat terraform.tfstate.lock.info

# Force unlock (use with caution!)
terraform force-unlock <LOCK_ID>
```

### Provider Issues

```bash
# Clear and reinitialize providers
rm -rf .terraform
terraform init
```

### State Drift

```bash
# Refresh state from actual infrastructure
terraform refresh

# See what changed
terraform plan
```

## Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [GitHub Provider](https://registry.terraform.io/providers/integrations/github/latest/docs)
- [Proxmox Provider](https://registry.terraform.io/providers/bpg/proxmox/latest/docs)
- [Module Development](https://developer.hashicorp.com/terraform/language/modules/develop)

## Best Practices

### Security

- Never hardcode secrets in `.tf` files
- Use `terraform.tfvars` for sensitive values (gitignored)
- Mark sensitive outputs with `sensitive = true`
- Use variable validation for security-critical inputs

### State Management

- State files are gitignored - never commit them
- Use remote state for production (Terraform Cloud/Enterprise)
- State files may contain secrets - handle with care
- Coordinate with team to avoid state conflicts

### Code Quality

- Use `count` or `for_each` to manage multiple resources
- Avoid duplication - use modules
- Document complex logic with comments
- Use meaningful variable descriptions

### Module Development

- Keep modules focused on single responsibility
- Provide sensible defaults in variables
- Document all inputs and outputs
- Include examples in module README

## GitHub Provider Specifics

### Repository Management

- Branch protection rules in dedicated modules
- Team management follows role-based patterns
- CODEOWNERS files generated from team structure

### Required Variables

```hcl
variable "github_token" {
  description = "GitHub personal access token"
  type        = string
  sensitive   = true
}

variable "github_owner" {
  description = "GitHub organization owner"
  type        = string
}
```

## Proxmox Provider Specifics

### VM Provisioning

- Use clone-vm module for consistent VM creation
- Define VM templates before cloning
- Network configuration in provider settings
- Storage pool mapping in variables

### Required Variables

```hcl
variable "proxmox_url" {
  description = "Proxmox API endpoint"
  type        = string
}

variable "proxmox_user" {
  description = "Proxmox username"
  type        = string
  sensitive   = true
}
```

## Common Tasks

### Adding a New Resource

1. Define variable(s) in `variables.tf` with description
2. Create resource in `main.tf`
3. Export outputs if needed in `outputs.tf`
4. Run `terraform fmt` and `terraform validate`
5. Test with `terraform plan`

### Creating a New Module

1. Create directory: `modules/<module-name>/`
2. Add `main.tf`, `variables.tf`, `outputs.tf`
3. Include `README.md` with usage example
4. Reference in root `main.tf` with `module` block

### Refactoring Resource

1. Update `main.tf` with changes
2. Run `terraform plan` to preview changes
3. Review state impact and dependencies
4. Apply and verify in target environment

## Troubleshooting

### Plan Shows Unexpected Changes

- Check variable values in `tfvars`
- Verify state file matches infrastructure
- Look for changes in computed fields

### Apply Fails

- Run `terraform validate` to check syntax
- Verify credentials and API access
- Check resource quotas in target platform
- Review error messages for specific requirements

### State Lock Issues

- Check for stale locks: `.terraform.tfstate.lock.info`
- Coordinate with team members
- Manual unlock only as last resort

## Related Documentation

- [Terraform Language Documentation](https://developer.hashicorp.com/terraform/language)
- [Module Development Best Practices](https://developer.hashicorp.com/terraform/language/modules/develop)
- [GitHub Provider Documentation](https://registry.terraform.io/providers/integrations/github/latest/docs)
- [Proxmox Provider Documentation](https://github.com/Telmate/terraform-provider-proxmox)

## Environment Variables

Set via Makefile or terminal:

```bash
ENV=staging make plan          # Use staging environment
ENV=production make plan       # Use production environment
```
