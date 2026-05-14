# GitHub Branch Protection Module

This module configures GitHub branch protection rules for repositories. By default, `enforce_admins` is `false` to allow repository admins to bypass rules when necessary.

## Features

- Configures required status checks
- Sets up pull request review requirements
- Allows admin bypass by default
- Supports code owner reviews
- Dismisses stale reviews on new pushes
- Supports strict status checks (requires up-to-date branches)

## Usage

```hcl
module "branch_protection" {
  source = "./modules/github-branch-protection"

  repository_id = "my-repo"
  branch        = "main"

  enforce_admins              = false
  dismiss_stale_reviews       = true
  require_code_owner_reviews  = true
  required_approving_review_count = 1

  required_status_check_contexts = ["ci/test", "ci/lint"]
}
```

## Features

- Classic branch protection for maximum control
- Status check requirements (optional)
- Pull request review requirements
- Code owner review enforcement
- Stale review dismissal on new pushes
- Admin bypass capability (default enabled)

## Notes

- Ensure the GitHub provider has admin permissions for the repository
- This module uses classic branch protection (not ruleset)
- Admin bypass (`enforce_admins = false`) allows emergency merges
- For CODEOWNERS file management, use the separate [GitHub CODEOWNERS module](../github-codeowners/README.md)

## Inputs

| Name                            | Description                              | Type           | Default  | Required |
| ------------------------------- | ---------------------------------------- | -------------- | -------- | -------- |
| repository_id                   | GitHub repository ID (org/repo or name)  | `string`       | n/a      | yes      |
| branch                          | Branch pattern to protect (default main) | `string`       | `"main"` | no       |
| github_owner                    | Repository owner (organization/user)     | `string`       | n/a      | yes      |
| enforce_admins                  | Enforce rules for admins                 | `bool`         | `false`  | no       |
| strict_required_status_checks   | Require branches to be up to date        | `bool`         | `true`   | no       |
| required_status_check_contexts  | List of required status check contexts   | `list(string)` | `[]`     | no       |
| dismiss_stale_reviews           | Dismiss stale pull request reviews       | `bool`         | `true`   | no       |
| require_code_owner_reviews      | Require code owner reviews               | `bool`         | `true`   | no       |
| required_approving_review_count | Number of required approving reviews     | `number`       | `1`      | no       |

## Outputs

| Name                 | Description                      |
| -------------------- | -------------------------------- |
| branch_protection_id | ID of the branch protection rule |

| Name              | Description                           |
| ----------------- | ------------------------------------- |
| branch_protection | The configured branch protection rule |
