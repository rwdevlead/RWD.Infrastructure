# Copilot Instructions for RWD.Infrastructure

## Purpose

This document serves as the primary instruction set for Claude Haiku 4.5 AI agents working with the RWD.Infrastructure project. It provides context for the project's architecture, conventions, and development practices. This document is maintained and updated throughout development conversations.

## Project Overview

**RWD.Infrastructure** is an Infrastructure-as-Code (IaC) repository implementing a complete automation ecosystem for enterprise infrastructure management.

### Technology Stack

- **Terraform (HCL)**: Infrastructure provisioning for Proxmox and GitHub
- **Packer (HCL)**: Golden image building for Ubuntu VM templates
- **Ansible (YAML)**: Post-deployment configuration management with 10+ application roles
- **Jinja2**: Dynamic configuration file templating
- **Shell/Bash**: VM lifecycle management and provisioning automation
- **Make**: Workflow orchestration across all tools
- **Docker/Docker Compose**: Application containerization and deployment

### Primary Goals

1. Automate infrastructure provisioning across Proxmox and cloud platforms
2. Ensure consistent, repeatable system configuration via Ansible
3. Build reusable VM templates with Packer for rapid deployment
4. Maintain version-controlled infrastructure code with secrets management
5. Provide automated workflows via Make for operational tasks

## Repository Structure

```
/Users/ka8kgj/Documents/Source/RWD.Infrastructure/
├── instructions/              # Language-specific AI instructions
│   ├── TERRAFORM.md          # Terraform/HCL guide
│   ├── ANSIBLE.md            # Ansible/YAML guide
│   ├── PACKER.md             # Packer/HCL guide
│   ├── JINJA2.md             # Jinja2 template guide
│   ├── SHELL.md              # Shell/Bash scripting guide
│   ├── MAKE.md               # Makefile orchestration guide
│   ├── copilot-instructions.md (THIS FILE)
│   └── Agents.md             # AI system integration guide
├── iac/
│   ├── terraform/            # Infrastructure provisioning
│   │   ├── github/          # GitHub organization management
│   │   ├── proxmox/         # Proxmox VM provisioning
│   │   └── modules/         # Reusable Terraform modules
│   ├── packer/              # Image building
│   │   └── ubuntu/
│   ├── ansible/             # Configuration management
│   │   ├── playbooks/       # Top-level orchestration
│   │   ├── roles/           # Reusable configuration roles
│   │   ├── inventories/     # Host definitions
│   │   └── vars/            # Global variables
│   └── (other tools)
├── Makefile                 # Central orchestration
├── README.md                # Project documentation
└── .github/
    └── copilot-instructions.md  # Project-level AI instructions
```

## Current State (March 30, 2026)

### Recent Development

1. **Docker NFS Mounts Integration** (Latest)
   - Created new `docker/nfs-mounts` role for NFS client setup
   - Configured mounts for `/mnt/docker` and `/mnt/backups`
   - Created subdirectories: `/mnt/docker/volumes`, `/mnt/docker/stacks`
   - Updated docker.yml playbook to include NFS setup before Docker installation

2. **Ansible Docker Playbook**
   - Installs Docker platform (engine + compose)
   - Configures NFS mounts for persistent storage
   - Supports Docker user group configuration

### Key Components Status

- ✅ Terraform: GitHub and Proxmox infrastructure definitions
- ✅ Packer: Ubuntu image building with cloud-init
- ✅ Ansible: 10+ application roles, base system configuration
- ✅ Docker: Platform setup with NFS integration
- ✅ Make: Unified orchestration across all tools

### Known Patterns

1. **Ansible Role Pattern**: Create dirs → Deploy config → Start services → Health check
2. **Docker Apps**: Use community.docker collection for compose orchestration
3. **NFS Mounts**: Install nfs-common, create mount points, mount with fstab persistence
4. **Error Handling**: Use `when: not ansible_check_mode` for service operations

## Development Workflow

### Standard Development Sequence

1. **Code Changes**: Modify Terraform, Ansible, Packer as needed
2. **Format & Validate**: Run `make lint` to check all code
3. **Plan Changes**: Create execution plan with `make plan`
4. **Review**: Check plan output for intended changes
5. **Apply**: Deploy changes with `make apply`
6. **Verify**: Confirm systems operational and healthy

### Using Make Commands

```bash
make help                      # List all available targets
make lint                      # Validate and format code
make plan ENV=<env>           # Create plan for environment
make apply ENV=<env>          # Apply to environment
make build                    # Build Packer images
```

### Environment Management

- **Default**: Local or test environment
- **Staging**: Pre-production testing environment
- **Production**: Live infrastructure environment

Set with: `ENV=env_name make target`

## Code Organization Principles

### Language-Specific

- **Terraform (HCL)**: Follow HashiCorp module structure; use vars/outputs; manage state carefully
- **Ansible (YAML)**: Role-based architecture; follow directory structure standards; use defaults consistently
- **Packer (HCL)**: Single source of truth for image builds; cloud-init for cloud-agnostic setup
- **Jinja2**: Dynamic configuration generation; use filters for safe output; maintain readability
- **Shell**: Minimal scripts; use set -euo pipefail; proper error handling; logging
- **Make**: Clear targets; dependency management; environment-aware execution

### Naming Conventions

- **Files**: lowercase with hyphens (terraform-apply.md) or underscores (terraform_vars.yml)
- **Directories**: lowercase with hyphens (github-repository)
- **Variables**: lowercase with underscores (vm_count, docker_version)
- **Constants**: UPPERCASE_WITH_UNDERSCORES (SCRIPT_DIR, PROXMOX_URL)

### Documentation

- Every role should have a README.md
- Every variable should have a description
- Complex logic should include comments
- Changes documented in commit messages

## Security Best Practices

### Secrets Management

- **Never commit**: tfvars files, variable files with sensitive data, SSH keys, API tokens
- **Use .gitignore**: State files, credentials, override files (see .gitignore)
- **Vault Integration**: Use `ansible-vault` for encrypted Ansible variables
- **Environment Variables**: Pass sensitive data via EN vars, not files
- **GitHub Secrets**: Use for CI/CD sensitive data

### Terraform State

- State files may contain secrets - handle carefully
- Never push state to version control
- Coordinate team access to avoid conflicts
- Use remote state in production (Terraform Cloud/Enterprise)

### Variable Handling

- Mark sensitive variables with `sensitive = true` in Terraform
- Never log sensitive data
- Use Ansible vault for encrypted inventories
- Rotate credentials regularly

## AI Agent Instructions

### When Working with This Repository

1. **Refer to language-specific guides**: Use TERRAFORM.md, ANSIBLE.md, etc. for detailed instructions
2. **Follow established patterns**: Look at existing roles, modules, and playbooks as templates
3. **Test before committing**: Use `--check` mode, `terraform plan`, etc.
4. **Update documentation**: Keep README files and comments current
5. **Validate syntax**: Always run lint/validate before considering work complete

### Common Tasks

- **Adding Terraform Resource**: Check TERRAFORM.md for module structure and conventions
- **Creating Ansible Role**: See ANSIBLE.md for role directory structure and patterns
- **Modifying Jinja2 Template**: Reference JINJA2.md for syntax and Ansible integration
- **Writing Shell Script**: Follow patterns in SHELL.md for structure and error handling
- **Adding Make Target**: Use patterns from MAKE.md for clarity and dependency management

### Key Reminders

- Terraform: Always run `terraform fmt` before committing
- Ansible: Use `ansible-lint` to check style
- Packer: Validate before building - builds are expensive
- Jinja2: Test rendering with `--check` mode
- Shell: Use `set -euo pipefail` and test extensively
- Make: Document targets clearly; use .PHONY declarations

## Testing and Validation

### Terraform

```bash
terraform fmt -recursive       # Format all HCL
terraform validate             # Check syntax
terraform plan -out=tfplan     # Preview changes
terraform apply tfplan         # Apply changes
```

### Ansible

```bash
ansible-lint                   # Check style/errors
ansible-playbook ... --check   # Dry-run
ansible-playbook ...           # Execute
```

### Packer

```bash
packer fmt .                   # Format HCL
packer validate template.hcl   # Check syntax
packer build template.hcl      # Build image
```

### Make

```bash
make help                      # List targets
make -p                        # Print all variables
make target -n                 # Show commands without executing
```

## Integration with Other AI Systems

See [Agents.md](Agents.md) for detailed instructions on:

- Integrating other Claude models or AI systems
- Sharing context and instructions across agents
- Unified workflow for multi-agent collaboration
- Custom agent roles and specialization

## Recent Conversation Notes

### March 30, 2026 - Docker NFS Integration

**Topic**: Preparing docker playbook for NFS mounts

- **Tasks Completed**:
  - Reviewed docker.yml playbook structure
  - Analyzed existing storage/nfs role for patterns
  - Created docker/nfs-mounts role with configurable mounts
  - Added mount point directories (/mnt/docker/volumes, /mnt/docker/stacks)
- **Mounts Configured**:
  - 192.168.50.13:/mnt/tank/docker → /mnt/docker (defaults,\_netdev)
  - 192.168.50.13:/mnt/tank/backups → /mnt/backups (defaults,\_netdev)
- **Next Steps**: Test docker playbook execution; verify mounts persistent

## How to Maintain This Document

### Update Guidelines

1. **After completing development tasks**: Document what was done and current state
2. **Before major feature work**: Note the starting point and approach
3. **When adding new patterns**: Document the pattern for future reference
4. **When discovering issues**: Note what was learned for troubleshooting
5. **Keep technical accuracy**: Verify details match actual codebase

### When to Create New Sections

- New language/tool adoption → Update technology stack and add instructions file
- New architectural pattern → Document in relevant language guide
- New project phase → Update "Current State" section
- Recurring issues → Add to troubleshooting in relevant guide

## Quick Reference

### Command Shortcuts

- Format all code: `make lint`
- Plan infrastructure: `make plan ENV=staging`
- Deploy infrastructure: `make apply ENV=staging`
- Check Ansible syntax: `ansible-lint`
- Build Packer image: `cd iac/packer/ubuntu && packer build ubuntu.pkr.hcl`

### File Locations

- Terraform configs: `iac/terraform/{github,proxmox}/`
- Ansible roles: `iac/ansible/roles/{apps,base,docker,storage}/`
- Packer templates: `iac/packer/ubuntu/`
- Global variables: `iac/ansible/vars/global.yml`
- Secrets (gitignored): `iac/ansible/vars/secrets.yml`

### Common Issues

- **Terraform plan shows changes**: Check tfvars matches intended state
- **Ansible fails in check mode**: Use `when: not ansible_check_mode` for certain operations
- **NFS mounts not persisting**: Verify `ansible.builtin.mount` uses `state: mounted`
- **Packer build fails**: Check cloud-init YAML syntax and Proxmox API access

## Related Documentation

- Project README: [README.md](../README.md)
- Terraform Guide: [instructions/TERRAFORM.md](TERRAFORM.md)
- Ansible Guide: [instructions/ANSIBLE.md](ANSIBLE.md)
- Packer Guide: [instructions/PACKER.md](PACKER.md)
- Jinja2 Guide: [instructions/JINJA2.md](JINJA2.md)
- Shell Guide: [instructions/SHELL.md](SHELL.md)
- Make Guide: [instructions/MAKE.md](MAKE.md)
- AI System Integration: [instructions/Agents.md](Agents.md)

---

**Last Updated**: March 30, 2026
**Status**: Active Development
**Maintainer**: Development Team
