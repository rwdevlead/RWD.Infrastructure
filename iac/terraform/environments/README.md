# Terraform Environments

This directory contains environment-specific Terraform configurations for different deployment targets.

## Environment Structure

Each environment is organized by platform or use case:

- **[github/](./github/)** - GitHub organization configurations
  - `realworlddevelopers/` - Real World Developers organization
  - `rwdevlead/` - RWD Leadership organization
- **[proxmox/](./proxmox/)** - Proxmox Virtual Environment configurations
  - `proxmox/` - Development/test Proxmox cluster
  - `pve-p01/` - Production Proxmox environment

## Root Module Pattern

Each environment directory (e.g., `github/realworlddevelopers/`) is a complete **Terraform root module**:

- Contains `main.tf`, `variables.tf`, `providers.tf`, and other configuration files
- References modules from `../../modules/`
- Has its own state file
- Can be initialized and applied independently

Example structure:

```
environments/
├── github/
│   ├── realworlddevelopers/
│   │   ├── main.tf                    # Repository and team configurations
│   │   ├── providers.tf               # Provider setup
│   │   ├── variables.tf               # Environment variables
│   │   └── *.tf                       # Repository-specific files
│   └── rwdevlead/
│       └── (similar structure)
└── proxmox/
    ├── proxmox/
    │   ├── main.tf                    # Template, VMs, storage
    │   ├── providers.tf
    │   └── variables.tf
    └── pve-p01/
        └── (similar structure)
```

## Working with Environments

### Initialize an Environment

```bash
cd environments/github/realworlddevelopers
terraform init
```

Or using the Makefile from the project root:

```bash
make init TARGET=github/realworlddevelopers
```

### Plan Changes

```bash
cd environments/github/realworlddevelopers
terraform plan
```

Or:

```bash
make plan TARGET=github/realworlddevelopers
```

### Apply Configuration

```bash
cd environments/github/realworlddevelopers
terraform apply
```

Or:

```bash
make apply TARGET=github/realworlddevelopers
```

## State Management

Each root module has its own state file:

```
environments/github/realworlddevelopers/
├── terraform.tfstate              # Current state
├── terraform.tfstate.backup       # Previous state
└── .terraform.tfstate.lock.info   # Lock file (when locked)
```

**Important:** State files are gitignored for security. They are local to each environment and contain sensitive information.

## Environment-Specific Configuration

Each environment can define its own:

- Variable values
- Provider configurations
- Resource naming conventions
- Scaling parameters

See individual environment README files for specifics.
