# Packer (HCL) Instructions

## Overview

Packer is used to build reusable machine images (templates) for consistent VM provisioning. Currently focused on Ubuntu image creation for Proxmox.

## Project Structure

```
iac/packer/
├── ubuntu/
│   ├── ubuntu.pkr.hcl           # Main build definition
│   ├── variables.pkr.hcl        # Variable definitions
│   ├── build.auto.pkrvars.hcl   # Build variables (auto-loaded)
│   ├── late-commands.sh         # Final provisioning script
│   └── http/                    # Cloud-init configurations
│       ├── meta-data
│       └── user-data
└── README.md
```

## File Organization

### Build Template File (ubuntu.pkr.hcl)

- **Purpose**: Define the image build process
- **Contains**: Source block, build block, provisioners
- **Naming**: `<os>.pkr.hcl` (e.g., ubuntu.pkr.hcl, centos.pkr.hcl)

### Variables File (variables.pkr.hcl)

- **Purpose**: Declare all input variables used in build
- **Naming**: Always `variables.pkr.hcl`
- **Convention**: Declare, don't assign values here

### Auto-Load Variables File (build.auto.pkrvars.hcl)

- **Purpose**: Provide actual variable values for build
- **Naming**: `*.auto.pkrvars.hcl` (auto-loaded by Packer)
- **Note**: Sensitive values should use environment or vault

### Cloud-Init Configuration (http/)

- **meta-data**: Instance metadata (typically empty for Proxmox)
- **user-data**: Cloud-init script run during first boot
- **Purpose**: Initial system configuration

### Provisioning Scripts (late-commands.sh)

- **Purpose**: Final customizations before image finalization
- **Execution**: Runs as root during build
- **Use for**: Clean-up, optimization, final tweaks

## Variable Naming Conventions

### Template Variables

- Snake_case: `vm_name`, `iso_checksum`, `memory_mb`
- Prefix with context: `proxmox_node`, `ubuntu_version`
- Descriptive: `disk_size_gb` not just `size`

### Environment Variables

- UPPERCASE_WITH_UNDERSCORES: `PROXMOX_USERNAME`, `PROXMOX_TOKEN`
- Sensitive information passed via environment

## Development Workflow

### Before Building

```bash
packer fmt .                    # Format HCL files
packer validate ubuntu.pkr.hcl  # Validate configuration
```

### Building Image

```bash
packer build ubuntu.pkr.hcl
```

### Using Make

```bash
make lint                       # Format and validate
make build ENV=staging          # Build for staging environment
```

## Best Practices

### Build Definition

- Use `source` block for each builder type
- Keep template generic with variables
- Use conditionals for environment-specific behavior
- Always validate before building

### Variables

- Provide descriptions for all variables
- Set `sensitive = true` for credentials
- Use `validation` blocks for inputs
- Provide sensible defaults where appropriate

### Provisioning

- Use cloud-init for cloud-agnostic setup
- Use shell provisioners for host-specific commands
- Order provisioners logically (install → configure → cleanup)
- Keep builds repeatable and idempotent

### Image Optimization

- Minimize final image size
- Clean package manager caches
- Remove temporary files
- Disable unnecessary services

## Proxmox-Specific Configuration

### Required Variables

```hcl
variable "proxmox_url" {
  type        = string
  description = "Proxmox API endpoint"
}

variable "proxmox_username" {
  type        = string
  description = "Proxmox username"
  sensitive   = true
}

variable "proxmox_token" {
  type        = string
  description = "Proxmox API token"
  sensitive   = true
}

variable "proxmox_node" {
  type        = string
  description = "Proxmox node to build on"
}
```

### Source Block Example

```hcl
source "proxmox-iso" "ubuntu" {
  proxmox_url          = var.proxmox_url
  username             = var.proxmox_username
  token                = var.proxmox_token
  node                 = var.proxmox_node
  vm_name              = var.vm_name
  iso_file             = var.iso_file
  iso_storage_pool     = "local"
  cores                = var.cpu_cores
  memory               = var.memory_mb
  os                   = "l26"  # Linux Kernel 2.6+
  template_description = var.template_description
}
```

### Cloud-Init Configuration

- **meta-data**: Keep minimal for Proxmox
- **user-data**: #cloud-config format
- **Typical setup**:
  - Update package lists
  - Install core packages (openssh, curl, etc.)
  - Configure networking
  - Set hostname via cloud-init

## Cloud-Init Best Practices

### user-data Structure

- Start with `#cloud-config` header
- Use YAML format
- Include inline scripts for complex logic
- Avoid long-running operations (build will timeout)

### Common Configuration

```yaml
#cloud-config
packages:
  - openssh-server
  - curl
  - wget

runcmd:
  - apt-get autoremove -y
  - apt-get clean
  - echo "Initialization complete"
```

### SSH Configuration

- Ensure SSH server installed and enabled
- Allow password authentication during build (disable after)
- Key configuration for Packer connectivity

## Build Lifecycle

### Stages

1. **ISO Download** - Fetch Ubuntu ISO (via checksum verification)
2. **VM Creation** - Create temporary Proxmox VM
3. **Cloud-Init** - Apply cloud-init configuration
4. **Provisioning** - Run provisioner scripts (shell, etc.)
5. **Cleanup** - Remove temporary files, finalize image
6. **Template** - Convert VM to template for cloning

### Success Criteria

- Image builds without errors
- SSH accessible during build
- Cloud-init completes successfully
- All provisioners execute successfully
- Template available in Proxmox for cloning

## Common Tasks

### Adding New Build Variable

1. Declare in `variables.pkr.hcl` with description
2. Add to `build.auto.pkrvars.hcl` with value
3. Reference in build block as `var.variable_name`
4. Test with `packer validate`

### Modifying Cloud-Init Configuration

1. Edit `http/user-data` file
2. Keep YAML syntax valid
3. Test with `packer validate`
4. Build to verify changes

### Adding Shell Provisioner

1. Add to build block in `ubuntu.pkr.hcl`
2. Script path relative to build directory
3. Use `remote_execution_order` to sequence
4. Ensure idempotency for safety

## Troubleshooting

### Build Fails at Cloud-Init

- Verify YAML syntax in `user-data`
- Check ISO cloud-init support
- Review Proxmox logs for errors
- Increase timeout if build too slow

### SSH Connection Fails

- Verify SSH installed in cloud-init
- Check network configuration
- Ensure password auth enabled
- Review Packer logs for connection details

### Template Not Created

- Check Proxmox permissions
- Verify `template_description` set
- Ensure VM build completed
- Check final provisioning steps succeeded

### Variable Not Found

- Verify variable declared in `variables.pkr.hcl`
- Check `.auto.pkrvars.hcl` for typos
- Ensure environment variables set if used
- Use `packer validate` to catch errors

## Environment Variables

### Setting Sensitive Values

```bash
export PROXMOX_USERNAME="root@pam"
export PROXMOX_TOKEN="your-token"
packer build ubuntu.pkr.hcl
```

### Variable Precedence

1. Command-line: `-var "key=value"`
2. Environment: `PKR_VAR_key=value`
3. Auto files: `*.auto.pkrvars.hcl`
4. Defaults: Variable default values

## Related Documentation

- [Packer Documentation](https://developer.hashicorp.com/packer/docs)
- [Proxmox Builder](https://developer.hashicorp.com/packer/plugins/builders/proxmox)
- [Cloud-Init Documentation](https://cloud-init.io/docs/)
- [Ubuntu Cloud Images](https://cloud-images.ubuntu.com/)
