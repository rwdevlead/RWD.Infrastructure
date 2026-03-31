# Terraform (HCL) Instructions

## Overview

Terraform is used for Infrastructure as Code with two primary targets:

- **Proxmox**: Virtual machine provisioning and management
- **GitHub**: Repository, team, and branch protection configuration

## Project Structure

```
iac/terraform/
├── github/           # GitHub organization management
├── proxmox/          # Proxmox VM provisioning
└── modules/          # Reusable Terraform modules
    ├── github-repository/
    ├── github-teams/
    ├── github-branch-protection/
    ├── clone-vm/
    ├── homeassistant/
    ├── template-ubuntu/
    └── truenas-vm/
```

## File Organization

### Core Files

- **main.tf**: Resource definitions
- **variables.tf**: Input variables with descriptions
- **outputs.tf**: Output values (if present)
- **providers.tf**: Provider configuration
- **terraform.tfvars**: Variable values (GITIGNORED - never commit)
- **tfplan**: Execution plan output (gitignored)

### Module Structure

Follow [HashiCorp Module Structure](https://developer.hashicorp.com/terraform/language/modules/develop/structure):

- Each module has its own `main.tf`, `variables.tf`, `outputs.tf`
- Modules are reusable and independently testable

## Development Workflow

### Before Committing

```bash
terraform fmt -recursive          # Format all HCL files
terraform validate                # Validate configuration syntax
terraform plan -out=tfplan        # Create execution plan
```

### Applying Changes

```bash
terraform apply "tfplan"          # Apply the planned changes
```

### Using with Make

```bash
make lint                         # Run validate and format
make plan                         # Create plan for current environment
make apply                        # Apply changes for current environment
ENV=production make plan          # Plan for specific environment
```

## Naming Conventions

### Resources

- Use snake_case for resource names
- Be descriptive: `aws_instance_web_server` not `aws_instance_1`
- Follow pattern: `<type>_<description>`

### Variables & Outputs

- Snake_case for all variable and output names
- Add descriptions to all variables
- Mark sensitive data with `sensitive = true`

### Modules

- Directory names with hyphens: `github-repository`
- Input variables use lowercase with underscores
- Follow [standard variable naming](https://developer.hashicorp.com/terraform/language/values/variables#variable-naming)

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
