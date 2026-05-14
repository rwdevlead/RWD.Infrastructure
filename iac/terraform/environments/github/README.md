# GitHub Terraform Environments

This directory contains environment-specific configurations for managing GitHub organizations.

## Organization Environments

### [realworlddevelopers/](./realworlddevelopers/)

Manages the **Real World Developers** GitHub organization.

**Configuration:**

- Organization: `realworlddevelopers`
- Repositories: Real World Developers projects
- Teams: Development, leadership, and specialized teams
- Access Control: Branch protection and CODEOWNERS management

**Key Features:**

- Multiple repository types (learning, tools, graphics)
- Team-based access control
- Automated CODEOWNERS file management
- Branch protection on main branches

---

### [rwdevlead/](./rwdevlead/)

Manages the **RWD Leadership** GitHub organization.

**Configuration:**

- Organization: `rwdevlead`
- Focus: Leadership and infrastructure repositories
- Teams: Admin and leadership teams
- Access Control: Strict branch protection and code review requirements

**Key Features:**

- Leadership repository management
- Strict access controls
- Comprehensive branch protection
- Infrastructure-as-code repositories

---

## Common Configuration

Both environments share a common local configuration pattern for repository and branch protection settings:

```hcl
locals {
  # Common repository features
  repo_features = {
    has_issues      = true
    has_wiki        = false
    has_discussions = true
    has_projects    = false
    auto_init       = true
  }

  # Branch protection settings
  branch_protection_settings = {
    enforce_admins                  = false  # Admins can bypass
    dismiss_stale_reviews           = true
    require_code_owner_reviews      = true
    required_approving_review_count = 1
  }

  managed_by = "Managed by Terraform"
}
```

## Repository Structure

Each environment's `main.tf` file typically includes:

1. **Repository Modules** - One per repository (e.g., `module "rwd_graphics"`)
2. **CODEOWNERS Modules** - One per repository (e.g., `module "codeowners_rwd_graphics"`)
3. **Optional Branch Protection** - For repositories requiring special rules

### Repository File Pattern

Individual repositories are often configured in separate files:

```
realworlddevelopers/
├── main.tf                          # Configuration
├── rwd-graphics.tf                  # Real World Developers Graphics
├── rwd-toolbox-*.tf                 # Toolbox repositories
├── rwd-web-react.tf                 # Web applications
└── winemakerssofter.tf              # Other projects
```

## Working with GitHub Environments

### Prerequisites

1. **GitHub Personal Access Token (PAT)**
   - Needs `repo`, `org:read`, and `admin:org_hook` scopes
   - Set via environment variable: `GITHUB_TOKEN`

2. **Provider Configuration**
   - Usually configured in `providers.tf`
   - May use multiple GitHub providers for different organizations

### Initialize Environment

```bash
export GITHUB_TOKEN="your_pat_token"
cd environments/github/realworlddevelopers
terraform init
```

### Preview Changes

```bash
terraform plan
```

### Apply Changes

```bash
terraform apply
```

## Managing Repositories

### Adding a New Repository

1. Create a new file (e.g., `new-project.tf`):

```hcl
module "new_project" {
  source = "../../modules/github-repository"

  repository_name = "new-project"
  description     = "New project description"
  visibility      = "private"

  has_issues      = local.repo_features.has_issues
  has_wiki        = local.repo_features.has_wiki
  has_discussions = local.repo_features.has_discussions
}

module "codeowners_new_project" {
  source = "../../modules/github-codeowners"

  repository = module.new_project.repository_name
  branch     = "main"

  admins = ["org/admins"]
  owners = ["org/owners"]
}
```

2. Plan and apply:

```bash
terraform plan
terraform apply
```

### Modifying Repository Settings

Edit the module parameters and apply:

```bash
# Edit the .tf file
terraform plan
terraform apply
```

## Important Notes

- **Managed by Terraform:** All repository configurations shown in this environment are managed through Terraform. Manual changes via GitHub UI will be overwritten.
- **State Files:** Keep state files secure and never commit them to Git
- **Provider Aliases:** Multiple providers can be used for multi-organization management
- **Import:** Existing repositories can be imported using `terraform import`

## See Also

- [GitHub Modules](../../modules/github/)
- [GitHub Terraform Provider Documentation](https://registry.terraform.io/providers/integrations/github/latest/docs)
