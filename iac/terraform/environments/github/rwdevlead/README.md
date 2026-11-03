# RWD Leadership GitHub Organization - Terraform

This directory contains the Terraform configuration for managing the **RWD Leadership** GitHub organization.

## Organization Overview

- **GitHub Organization:** rwdevlead
- **Purpose:** Leadership and infrastructure management
- **Repositories:** Leadership, infrastructure, and internal projects
- **Teams:** Admin and leadership teams
- **Access Control:** Strict branch protection and code review requirements

## Repository Categories

The organization maintains repositories for different purposes:

### Managed Repositories

- **rwd-agents** - Shared AI agents guidance and developer tooling
- **rwd-graphics** - Graphics and branding assets
- **rwd-infrastructure-diagram** - Infrastructure topology diagrams and documentation
- **rwd-numpicker** - Number selection utility
- **rwd-poker-clock** - Poker tournament clock timer application
- **rwd-web-react** - React-based web applications
- **winemakerssofter** - Community winemaking software

## Repository Configuration

All repositories follow a standard configuration pattern:

```hcl
locals {
  repo_features = {
    has_issues      = true       # Issues for tracking
    has_wiki        = false      # Use external documentation
    has_discussions = true       # Community discussions
    has_projects    = false      # Projects disabled
    auto_init       = true       # Auto-initialize with README
  }

  branch_protection_settings = {
    enforce_admins                  = false
    dismiss_stale_reviews           = true
    require_code_owner_reviews      = true
    required_approving_review_count = 1
  }
}
```

## Branch Protection

All repositories implement consistent branch protection on `main`:

| Setting                    | Value | Purpose                               |
| -------------------------- | ----- | ------------------------------------- |
| Enforce Admins             | false | Allow admin overrides for emergencies |
| Dismiss Stale Reviews      | true  | Require fresh reviews on updates      |
| Require Code Owner Reviews | true  | Enforce CODEOWNERS approval           |
| Required Approving Reviews | 1     | Require at least one approval         |

## Team Structure

Teams manage access and responsibility:

- **admins** - Organization administrators with full access
- **owners** - Repository owners with merge permissions
- **maintainers** - Core infrastructure maintainers

## CODEOWNERS Management

Each repository has an automated CODEOWNERS file managed by Terraform:

```hcl
module "codeowners_infrastructure" {
  source = "../../modules/github-codeowners"

  repository = module.rwd_infrastructure.repository_name
  branch     = "main"

  admins = ["rwdevlead/admins"]
  owners = ["rwdevlead/owners"]

  extra_rules = {
    "/iac/terraform/*"  = "rwdevlead/infrastructure"
    "/iac/ansible/*"    = "rwdevlead/infrastructure"
    "/iac/packer/*"     = "rwdevlead/infrastructure"
  }
}
```

**Global Owners:**

- `@rwdevlead/admins` - Admin team
- `@rwdevlead/owners` - Owner team

**Path-Specific Owners:**

- Infrastructure code owned by infrastructure team

## Adding New Repositories

1. **Create a new configuration file** (e.g., `new-project.tf`):

```hcl
module "new_project" {
  source = "../../modules/github-repository"

  repository_name = "new-project"
  description     = "Description of the new project"
  visibility      = "private"

  topics          = ["infrastructure", "leadership"]
  has_issues      = local.repo_features.has_issues
  has_wiki        = local.repo_features.has_wiki
  has_discussions = local.repo_features.has_discussions
  has_projects    = local.repo_features.has_projects
  auto_init       = local.repo_features.auto_init
}

module "branch_protection_new_project" {
  source = "../../modules/github-branch-protection"

  repository_id                   = module.new_project.repository_name
  branch                          = "main"
  enforce_admins                  = local.branch_protection_settings.enforce_admins
  dismiss_stale_reviews           = local.branch_protection_settings.dismiss_stale_reviews
  require_code_owner_reviews      = local.branch_protection_settings.require_code_owner_reviews
  required_approving_review_count = local.branch_protection_settings.required_approving_review_count
}

module "codeowners_new_project" {
  source = "../../modules/github-codeowners"

  repository = module.new_project.repository_name
  branch     = "main"

  admins = ["rwdevlead/admins"]
  owners = ["rwdevlead/owners"]
}
```

2. **Plan and apply:**

```bash
terraform plan
terraform apply
```

## Working with This Configuration

### Prerequisites

- Infisical Machine Identity credentials configured in repository `.env` (`INFISICAL_CLIENT_ID`, `INFISICAL_CLIENT_SECRET`, `INFISICAL_PROJECT_ID`).
- GitHub token and organization are retrieved automatically from the Infisical vault at `/terraform/github/rwdevlead`.

### Operations via Makefile

All actions should be run from the repository root:

```bash
# Initialize Terraform
make init TARGET=github/rwdevlead

# Plan changes
make plan TARGET=github/rwdevlead

# Apply changes
make apply TARGET=github/rwdevlead
```

## File Organization

```
rwdevlead/
├── main.tf                          # Organization settings and default feature flags
├── data.tf                          # Infisical vault data source
├── locals.tf                        # Secret extraction (GITHUB_TOKEN, GITHUB_OWNER)
├── providers.tf                     # Provider setups (Infisical, GitHub, HCP cloud)
├── variables.tf                     # Input variables (Infisical credentials)
├── rwd-agents.tf                    # Shared agents guidance repository & CODEOWNERS
├── rwd-graphics.tf                  # Graphics/branding repository & CODEOWNERS
├── rwd-infrastructure-diagram.tf    # Infrastructure diagrams repository & CODEOWNERS
├── rwd-numpicker.tf                 # Num picker utility repository & CODEOWNERS
├── rwd-poker-clock.tf               # Poker clock utility repository & CODEOWNERS
├── rwd-web-react.tf                 # React web repository & CODEOWNERS
└── winemakerssofter.tf              # Community winemaking project & CODEOWNERS
```

## Important Notes

- **Terraform Managed:** All configurations are managed by Terraform. Manual changes in GitHub UI will be overwritten.
- **Strict Access Control:** Leadership organization has stricter branch protection settings
- **State Files:** Never commit state files - they contain sensitive information
- **API Tokens:** Protect GitHub tokens - they have organization-level access
- **Testing:** Always use `terraform plan` to preview changes before applying
- **Emergency Bypass:** `enforce_admins = false` allows admins to bypass rules for critical fixes

## Common Tasks

### Viewing Planned Changes

```bash
terraform plan
```

### Applying Configuration

```bash
terraform apply
```

### Destroying Resources

```bash
# WARNING: This will delete GitHub repositories!
terraform destroy
```

### Refreshing State

```bash
terraform refresh
```

## See Also

- [GitHub Modules Documentation](../../modules/github/)
- [GitHub Terraform Provider](https://registry.terraform.io/providers/integrations/github/latest/docs)
- [Parent Directory README](../README.md)
- [Real World Developers Organization](../realworlddevelopers/README.md)
