# AI Agent Instructions for RWD.Infrastructure

## Project Overview

This project manages infrastructure and configuration using:

- Terraform for infrastructure provisioning
- Packer for image building and management
- Ansible for configuration management and automation

The project is currently in its initial setup phase.

## Repository Structure

- `.terraform/` - Local Terraform working directory (gitignored)
- `.vscode/` - VS Code workspace settings and tasks
- `Makefile` - Common automation tasks and workflows
- `env/` - Environment-specific configurations (gitignored except examples)
- Terraform state files (`*.tfstate`, `*.tfstate.*`) are gitignored
- Variable files (`*.tfvars`, `*.tfvars.json`) are gitignored for security
- Override files (`override.tf`, `*_override.tf`) are gitignored but can be included using negated patterns

## Development Workflow

1. **Infrastructure Changes (Terraform)**
   - Always run `terraform fmt` before committing changes
   - Use `terraform validate` to check configuration
   - Create a plan with `terraform plan -out=tfplan`
   - Apply changes with `terraform apply "tfplan"`

2. **Image Building (Packer)**
   - Use `packer fmt` to format HCL configurations
   - Validate templates with `packer validate`
   - Build images with `packer build`
   - Use variables files for environment-specific settings

3. **Configuration Management (Ansible)**
   - Use `ansible-lint` before committing playbook changes
   - Test playbooks with `ansible-playbook --check`
   - Use vault for sensitive data (`ansible-vault`)
   - Follow roles-based organization for playbooks

4. **Common Tasks (Makefile)**
   - Use `make help` to list available commands
   - Run `make lint` to check all configurations
   - Use `make plan` for Terraform planning
   - Execute `make apply` for full infrastructure deployment
   - Environment selection via `ENV=<env> make <target>`

5. **VS Code Integration**
   - Use integrated terminals for command execution
   - Tasks are configured in `.vscode/tasks.json`
   - Debug configurations in `.vscode/launch.json`
   - Recommended extensions in `.vscode/extensions.json`

6. **State Management**
   - State files are gitignored to prevent secrets exposure
   - Coordinate with team members when making changes to avoid state conflicts
   - Use state locking (`.terraform.tfstate.lock.info` is gitignored)

## Standard Docker Application Deployment Pattern

All Docker application deployments must follow this pattern to ensure production-ready, testable, and maintainable configurations:

### 1. Directory Structure

Each app should create these persistent directories on the Docker host:

```
/mnt/docker/{app-name}/
├── config/          # Configuration files
├── acme/           # Certificate storage (if needed)
├── volumes/        # Persistent user data
└── logs/           # Application logs (optional)
```

### 2. Environment Variable Management

- Store secrets and configuration in `.env` file (not in git)
- Use `.env.example` as a template showing required variables
- Copy template to actual `.env` before deployment: `cp .env.example .env`
- Reference: `.env.example` at repository root

**Required Variables:**

- `CF_DNS_API_TOKEN` - For ACME DNS-01 validation (Cloudflare)
- Any API keys, passwords, or credentials specific to the app

### 3. Health Checks (REQUIRED)

All Docker apps must include health checks in the deployment tasks:

- **Container health check**: Verify Docker container health status
- **Endpoint verification**: Confirm service is actually responding to requests
- **Assertion**: Verify both conditions before declaring success
- **Check mode handling**: Use `when: not ansible_check_mode` to skip during dry-runs

See [ANSIBLE.md - Docker Application Deployment Patterns](./instructions/ANSIBLE.md#docker-application-deployment-patterns) for exact implementation.

### 4. Docker Compose Configuration

- Use Jinja2 templates (`.j2` extension) for dynamic configuration
- Include health checks in compose service definitions
- Use environment variables from `.env` for secrets
- Define external `traefik` network for reverse proxy integration

### 5. Volume Management

- Mount volumes from persistent directories created in step 1
- Use NFS mounts where applicable (for multi-host scenarios)
- Ensure proper permissions (0777 for Docker access, 0600 for secrets)

## Security Considerations

- Never commit `.tfvars` files as they may contain sensitive data
- Use variable files for environment-specific configurations
- CLI configuration files (`.terraformrc`, `terraform.rc`) are gitignored
- Use `ansible-vault` for encrypting sensitive Ansible variables
- Keep Packer variables with secrets in `.pkrvars.hcl` files (gitignored)
- Store all credentials and secrets in a secure vault service

## Conventions

- Follow HashiCorp's [standard module structure](https://developer.hashicorp.com/terraform/language/modules/develop/structure)
- Use consistent naming for resources and data sources
- Document all variables and outputs
- Use override files for local development tweaks

## Current Deployment Status

### Traefik v3.6.1 (Reverse Proxy & Load Balancer)

- **Status**: Hardened for production with health checks and secure configuration
- **Implementation**: Ansible role at `iac/ansible/roles/apps/traefik/`
- **Key Features**:
  - Automatic wildcard certificate generation via Let's Encrypt (DNS-01)
  - Cloudflare API integration for DNS challenges
  - Health check assertions (container + endpoint verification)
  - Persistent ACME storage at `/mnt/docker/traefik/acme/`
  - Dynamically configured middleware and routing
  - Docker service discovery via labels
- **Deployment**: `ansible-playbook playbooks/traefik.yml`
- **Documentation**: See [traefik role README](../iac/ansible/roles/apps/traefik/README.md#certificate-management)

### NFS Storage Integration

- **Status**: Fully integrated with Docker applications
- **Implementation**: `iac/ansible/roles/docker/nfs-mounts/`
- **Mounts**:
  - `/mnt/docker/` (from 192.168.50.13:/mnt/tank/docker)
  - `/mnt/backups/` (from 192.168.50.13:/mnt/tank/backups)
- **Subdirectories**: `/mnt/docker/{volumes,stacks,traefik,pihole,...,etc}`

## Key Integration Points

- Infrastructure changes should be coordinated with the application deployment process
- Consider dependencies between resources when making changes
- Docker applications must follow standard pattern (health checks, volumes, .env)
- New app deployments should use Traefik as reverse proxy (external traefik network)
- Certificate renewals are automatic via Let's Encrypt - monitor `/mnt/docker/traefik/logs/`

This is a living document - please help keep it updated as the project evolves!
