# Terraform Modules

This directory contains reusable Terraform modules for infrastructure provisioning across multiple platforms.

## Module Organization

Modules are organized by platform:

- **[github/](./github/)** - GitHub organization and repository management modules
- **[proxmox/](./proxmox/)** - Proxmox virtual environment infrastructure modules

## Using Modules

Each module is self-contained and can be used independently in root module configurations. Modules are referenced using relative paths:

```hcl
module "example" {
  source = "../modules/github/github-repository"

  # Module-specific variables
}
```

## Module Structure

Each module follows this standard structure:

```
module-name/
├── README.md          # Module documentation
├── main.tf            # Primary resource definitions
├── variables.tf       # Input variables
├── outputs.tf         # Output values
```

### Documentation Requirements

Every module includes a README.md with:

- Module description and purpose
- Features and capabilities
- Usage examples
- Input variables table
- Output values table
- Important notes and warnings

## Module Versioning

Modules are versioned implicitly through the Git repository. When referencing modules in environments, always use specific versions or tags for production deployments:

```hcl
module "example" {
  source = "git::https://github.com/your-org/your-repo.git//modules/github/github-repository?ref=v1.0.0"
}
```

For local development, use relative paths as shown above.
