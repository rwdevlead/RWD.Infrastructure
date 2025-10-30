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

## Key Integration Points

- Infrastructure changes should be coordinated with the application deployment process
- Consider dependencies between resources when making changes

This is a living document - please help keep it updated as the project evolves!
