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

### Infrastructure & Tools

- **RWD.Infrastructure** - Infrastructure as Code (Terraform, Ansible, Packer)
- **RWD.Automation** - Automation and deployment scripts

### Leadership & Documentation

- **RWD.Leadership** - Leadership documentation and policies
- **RWD.Governance** - Organization governance and processes

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

- GitHub Personal Access Token with organization admin permissions
- Token requires: `repo`, `admin:org`, `admin:org_hook` scopes
- Set `GITHUB_TOKEN` environment variable

### Initialize

```bash
export GITHUB_TOKEN="your_pat_token"
terraform init
```

### Plan Changes

```bash
terraform plan
```

### Apply Changes

```bash
terraform apply
```

### Import Existing Repository

```bash
terraform import 'module.rwd_infrastructure.github_repository.this' "RWD.Infrastructure"
```

## File Organization

```
rwdevlead/
├── main.tf                      # Configuration and locals
├── providers.tf                 # GitHub provider setup
├── variables.tf                 # Input variables
├── rwd-graphics.tf              # Graphics/branding repository
├── rwd-numpicker.tf             # Num picker project
├── rwd-web-react.tf             # React web applications
├── winemakerssofter.tf          # Community wine project
└── terraform.tfstate*           # State files (gitignored)
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
