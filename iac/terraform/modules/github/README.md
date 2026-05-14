# GitHub Terraform Modules

This directory contains modules for managing GitHub organizations, repositories, teams, and access controls using Terraform.

## Modules

### [github-repository](./github-repository/)

Creates and manages GitHub repositories with configurable settings.

**Features:**

- Repository creation with customizable visibility
- Topics and feature toggles (issues, wiki, discussions)
- Delete branch on merge
- Vulnerability alerts enabled by default

**Key Variables:**

- `repository_name` - Name of the GitHub repository
- `visibility` - Repository visibility: public, private, or internal
- `topics` - List of repository topics
- `has_issues`, `has_projects`, `has_wiki`, `has_discussions` - Feature toggles

**Outputs:**

- `repository_id` - The GitHub repository node ID
- `repository_url` - The HTML URL of the repository
- `repository_name` - The repository name

---

### [github-teams](./github-teams/)

Creates GitHub teams and manages team memberships.

**Features:**

- Bulk team creation
- Team member management
- Team descriptions for organization

**Key Variables:**

- `github_owner` - The GitHub organization or user that owns the teams
- `teams` - Map of team definitions with descriptions and member lists

**Outputs:**

- `team_slugs` - Map of team slugs keyed by team name
- `team_ids` - Map of team IDs keyed by team name

---

### [github-branch-protection](./github-branch-protection/)

Configures GitHub branch protection rules for repositories.

**Features:**

- Required status checks
- Pull request review requirements
- Code owner review enforcement
- Admin bypass capability
- Stale review dismissal

**Key Variables:**

- `repository_id` - GitHub repository ID (org/repo)
- `branch` - Branch pattern to protect
- `enforce_admins` - Whether to enforce rules for admins (default: false)
- `required_approving_review_count` - Number of required approving reviews
- `require_code_owner_reviews` - Require code owner reviews

**Outputs:**

- `branch_protection_id` - ID of the branch protection resource

---

### [github-codeowners](./github-codeowners/)

Manages CODEOWNERS files in GitHub repositories.

**Features:**

- Automatic CODEOWNERS file generation
- Global owner configuration (admins, owners)
- Path-specific ownership rules
- Requires owner lookups via GitHub API

**Key Variables:**

- `repository` - Target repository name (org/repo)
- `branch` - Target branch (typically "main")
- `admins` - List of admin team slugs
- `owners` - List of owner team slugs
- `extra_rules` - Map of path-specific ownership rules

**Outputs:**

- `codeowners_content` - Rendered CODEOWNERS file content
- `owner_ids` - Map of CODEOWNERS user IDs by username

---

## Usage Pattern

Most GitHub modules are used together to create a fully configured repository:

```hcl
# Create repository
module "my_repo" {
  source = "./modules/github-repository"

  repository_name = "my-repo"
  description     = "My repository"
  visibility      = "private"

  has_issues      = true
  has_discussions = true
}

# Set up teams (if needed)
module "teams" {
  source = "./modules/github-teams"

  github_owner = "my-org"

  teams = {
    "developers" = {
      description = "Development team"
      members     = ["user1", "user2"]
    }
  }
}

# Configure branch protection
module "branch_protection" {
  source = "./modules/github-branch-protection"

  repository_id = module.my_repo.repository_name
  branch        = "main"

  require_code_owner_reviews      = true
  required_approving_review_count = 1
}

# Manage CODEOWNERS
module "codeowners" {
  source = "./modules/github-codeowners"

  repository = module.my_repo.repository_name
  branch     = "main"

  admins = ["org/admins"]
  owners = ["org/owners"]
}
```

## Environment Configuration

See [../environments/github/](../environments/github/) for environment-specific configurations.
