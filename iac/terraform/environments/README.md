# Terraform Environments

This directory contains environment-specific Terraform configurations for different deployment targets.

## Environment Structure

Each environment is organized by platform or use case:

- **[github/](./github/)** - GitHub organization configurations
  - `realworlddevelopers/` - Real World Developers organization
  - `rwdevlead/` - RWD Leadership organization
- **[proxmox/](./proxmox/)** - Proxmox Virtual Environment configurations
  - `proxmox/` - Development/test Proxmox cluster
  - `pve-d01/` - Development standalone Proxmox node
  - `pve-p01/` - Production Proxmox environment
- **[infisical/](./infisical/)** - Infisical secret management testing environment

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
├── infisical/
│   ├── main.tf                        # Infisical secret retrieval testing
│   ├── providers.tf                   # Infisical provider & HCP cloud workspace
│   └── variables.tf                   # Machine identity variables
└── proxmox/
    ├── proxmox/
    │   ├── main.tf                    # Template, VMs, storage
    │   ├── providers.tf
    │   └── variables.tf
    ├── pve-d01/
    │   └── (similar structure)
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

## State Management & HCP Terraform Authentication

All environments in this repository manage state remotely using **HCP Terraform (Terraform Cloud)** under organization `realworlddevelopers` and project `RWD Infrastructure`.

### Acquiring the Terraform Token
- **Using `terraform login`:** To authenticate your local workstation, run:
  ```bash
  terraform login
  ```
  Follow the terminal prompts to open the browser, create an API token, and allow Terraform to store it in `~/.terraform.d/credentials.tfrc.json`.
- **Not Stored in Infisical:** **The Terraform Cloud user API token is NOT stored in Infisical.** It must be generated and managed directly on your workstation via `terraform login`. Infisical manages secrets such as Infisical credentials, GitHub tokens, and Proxmox credentials, but does not manage the CLI's HCP Terraform authentication token.
- **Token Expiration:** If `make init` or `make plan` reports an `unauthorized` error against `app.terraform.io`, refresh your credentials by re-running `terraform login`.

## Environment-Specific Configuration

Each environment can define its own:

- Variable values
- Provider configurations
- Resource naming conventions
- Scaling parameters

See individual environment README files for specifics.
