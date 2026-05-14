# GitHub CODEOWNERS Module

This Terraform module creates and manages CODEOWNERS files in GitHub repositories for automated code owner review enforcement.

## Features

- Automatically generates CODEOWNERS content
- Supports global owners (admins and owners teams)
- Allows path-specific ownership rules
- Creates the `.github/CODEOWNERS` file in the repository
- Integrates with GitHub's code review requirements

## Usage

```hcl
module "codeowners" {
  source = "./modules/github-codeowners"

  repository = "my-org/my-repo"
  branch     = "main"

  admins = ["my-org/admins"]
  owners = ["my-org/owners"]

  extra_rules = {
    "/frontend/*" = "@my-org/frontend-team"
    "/backend/*"  = "@my-org/backend-team"
  }
}
```

## Generated CODEOWNERS File

```
# CODEOWNERS
# Automatically managed by Terraform.
# Do not edit manually.

# Global owners
* @my-org/admins
* @my-org/owners

# Additional ownership rules
/frontend/* @my-org/frontend-team
/backend/* @my-org/backend-team
```

## How It Works

1. Module accepts lists of admin and owner teams
2. Generates CODEOWNERS file content
3. Looks up user IDs for the specified teams
4. Creates the `.github/CODEOWNERS` file in the repository

## Integration with Branch Protection

Use with [github-branch-protection](../github-branch-protection/) module to enforce code owner reviews:

```hcl
module "branch_protection" {
  source = "./modules/github-branch-protection"

  repository_id            = module.repository.repository_name
  require_code_owner_reviews = true  # Enforces CODEOWNERS review
}
```

## Inputs

| Name         | Description                               | Type           | Default  | Required |
| ------------ | ----------------------------------------- | -------------- | -------- | -------- |
| repository   | Repository name (org/repo)                | `string`       | n/a      | yes      |
| branch       | Branch to create the file in              | `string`       | `"main"` | no       |
| github_owner | GitHub organization or user               | `string`       | n/a      | yes      |
| admins       | List of admin team slugs (GitHub handles) | `list(string)` | `[]`     | no       |
| owners       | List of owner team slugs (GitHub handles) | `list(string)` | `[]`     | no       |
| extra_rules  | Map of path patterns to owners            | `map(string)`  | `{}`     | no       |

**Note:** Team slugs should include the organization prefix, e.g., `@org/team-name`.

## Outputs

| Name               | Description                       |
| ------------------ | --------------------------------- |
| codeowners_content | Rendered CODEOWNERS file content  |
| owner_ids          | Map of owner user IDs by username |
