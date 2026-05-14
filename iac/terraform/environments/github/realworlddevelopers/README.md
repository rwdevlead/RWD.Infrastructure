# Real World Developers GitHub Organization - Terraform

This directory contains the Terraform configuration for managing the **Real World Developers** GitHub organization.

## Organization Overview

- **GitHub Organization:** realworlddevelopers
- **Purpose:** Open source projects and learning resources
- **Repositories:** Multiple project repositories with consistent settings
- **Teams:** Development teams and specialized groups

## Repository Categories

The organization maintains repositories across several categories:

### Toolbox Projects

A collection of developer utility tools:

- **rwd-toolbox-address-parser** - Address parsing utility
- **rwd-toolbox-conversion** - Unit and format conversion tool
- **rwd-toolbox-logging** - Logging utilities
- **rwd-toolbox-password-generator** - Secure password generation
- **rwd-toolbox-smtp** - SMTP email utilities
- **rwd-toolbox-ui-middleware** - UI middleware components

### Media & Resources

- **rwd-graphics** - Graphics and branding assets

### Web Applications

- **rwd-web-react** - React-based web applications

### Community Projects

- **winemakerssofter** - Community wine-making project

## Repository Configuration

All repositories follow a standard configuration pattern:

```hcl
locals {
  repo_features = {
    has_issues      = true       # Issues enabled for bug tracking
    has_wiki        = false      # Wiki disabled (use external docs)
    has_discussions = true       # Discussions for community
    has_projects    = false      # Projects disabled
    auto_init       = true       # Auto-initialize with README
  }
}
```

## Branch Protection

All repositories implement the following branch protection on `main`:

| Setting                    | Value                         |
| -------------------------- | ----------------------------- |
| Enforce Admins             | false (admins can bypass)     |
| Dismiss Stale Reviews      | true                          |
| Require Code Owner Reviews | true                          |
| Required Approving Reviews | 1                             |
| Require Status Checks      | false (configurable per repo) |

## Team Structure

Teams are organized by function and project:

- **admins** - Organization admins
- **owners** - Repository owners
- **developers** - Core development team
- **maintainers** - Project maintainers

## CODEOWNERS Management

Each repository has an automated CODEOWNERS file managed by Terraform:

```hcl
module "codeowners_rwd_graphics" {
  source = "../../modules/github-codeowners"

  repository = module.rwd_graphics.repository_name
  branch     = "main"

  admins = ["realworlddevelopers/admins"]
  owners = ["realworlddevelopers/owners"]
}
```

**Global Owners:**

- `@realworlddevelopers/admins` - Admin team
- `@realworlddevelopers/owners` - Owner team

## Adding New Repositories

1. **Create a new `.tf` file** (e.g., `new-project.tf`):

```hcl
module "new_project" {
  source = "../../modules/github-repository"

  repository_name = "new-project"
  description     = "Description of the new project"
  visibility      = "private"  # or "public"

  topics          = ["tag1", "tag2"]
  has_issues      = local.repo_features.has_issues
  has_wiki        = local.repo_features.has_wiki
  has_discussions = local.repo_features.has_discussions
  has_projects    = local.repo_features.has_projects
  auto_init       = local.repo_features.auto_init
}

# Add branch protection if needed
module "branch_protection_new_project" {
  source = "../../modules/github-branch-protection"

  repository_id                   = module.new_project.repository_name
  branch                          = "main"
  enforce_admins                  = local.branch_protection_settings.enforce_admins
  dismiss_stale_reviews           = local.branch_protection_settings.dismiss_stale_reviews
  require_code_owner_reviews      = local.branch_protection_settings.require_code_owner_reviews
  required_approving_review_count = local.branch_protection_settings.required_approving_review_count
}

# Add CODEOWNERS management
module "codeowners_new_project" {
  source = "../../modules/github-codeowners"

  repository = module.new_project.repository_name
  branch     = "main"

  admins = ["realworlddevelopers/admins"]
  owners = ["realworlddevelopers/owners"]
}
```

2. **Plan changes:**

```bash
terraform plan
```

3. **Apply configuration:**

```bash
terraform apply
```

## Working with This Configuration

### Prerequisites

- GitHub Personal Access Token with appropriate scopes
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

If a repository was manually created, import it:

```bash
terraform import 'module.rwd_graphics.github_repository.this' "rwd-graphics"
```

## File Organization

```
realworlddevelopers/
├── main.tf                      # Configuration and locals
├── providers.tf                 # GitHub provider setup
├── variables.tf                 # Input variables
├── rwd-graphics.tf              # Real World Developers Graphics
├── rwd-toolbox-*.tf             # Toolbox repositories (6 files)
├── rwd-web-react.tf             # Web applications
├── winemakerssofter.tf          # Community projects
└── terraform.tfstate*           # State files (gitignored)
```

## Important Notes

- **Terraform Managed:** All configurations in this directory are managed by Terraform. Manual GitHub UI changes will be overwritten.
- **State Files:** Never commit state files to version control
- **API Tokens:** Protect your GitHub API token - it has organization-level access
- **Branch Names:** Main branch is `main` for all repositories
- **Testing:** Use `terraform plan` to preview changes before applying

## See Also

- [GitHub Modules Documentation](../../modules/github/)
- [GitHub Terraform Provider](https://registry.terraform.io/providers/integrations/github/latest/docs)
- [Parent Directory README](../README.md)
