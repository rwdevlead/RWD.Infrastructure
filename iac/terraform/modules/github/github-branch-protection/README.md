# GitHub Branch Protection Module

This module configures classic GitHub branch protection rules for repositories, with `enforce_admins` defaulting to `false` to allow repository admins to bypass the rules.

## Features

- Configures required status checks
- Sets up pull request review requirements
- Allows admin bypass by default
- Supports code owner reviews

## Usage

```hcl
module "branch_protection" {
  source = "./modules/github-branch-protection"

  repository_id = "org/repo-name"
  branch        = "main"

  enforce_admins = false

  required_status_check_contexts = ["ci/test", "ci/lint"]

  dismiss_stale_reviews           = true
  require_code_owner_reviews      = true
  required_approving_review_count = 1
}
```

## Notes

- Ensure the GitHub provider is configured in the root module with credentials that have admin permissions for the repository.
- This module uses classic branch protection to allow admins to bypass rules when needed.
- For CODEOWNERS management, use the separate [GitHub CODEOWNERS module](../github-codeowners/README.md).

## Inputs

| Name                            | Description                            | Type           | Default | Required |
| ------------------------------- | -------------------------------------- | -------------- | ------- | -------- |
| repository_id                   | GitHub repository ID (org/repo)        | `string`       | n/a     | yes      |
| branch                          | Branch pattern to protect              | `string`       | n/a     | yes      |
| enforce_admins                  | Whether to enforce rules for admins    | `bool`         | `false` | no       |
| strict_required_status_checks   | Require branches to be up to date      | `bool`         | `false` | no       |
| required_status_check_contexts  | List of required status check contexts | `list(string)` | `[]`    | no       |
| dismiss_stale_reviews           | Dismiss stale pull request reviews     | `bool`         | `false` | no       |
| require_code_owner_reviews      | Require code owner reviews             | `bool`         | `false` | no       |
| required_approving_review_count | Number of required approving reviews   | `number`       | `1`     | no       |

## Outputs

| Name              | Description                           |
| ----------------- | ------------------------------------- |
| branch_protection | The configured branch protection rule |
