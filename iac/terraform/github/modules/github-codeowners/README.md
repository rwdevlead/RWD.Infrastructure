# GitHub CODEOWNERS Module

This Terraform module creates and manages CODEOWNERS files in GitHub repositories.

## Features

- Automatically generates CODEOWNERS content
- Supports global owners (admins and owners teams)
- Allows additional ownership rules for specific paths
- Creates the .github/CODEOWNERS file in the repository

## Usage

```hcl
module "codeowners" {
  source = "./modules/github-codeowners"

  repository = "org/repo-name"
  branch     = "main"

  admins = ["org/admins"]
  owners = ["org/owners"]

  extra_rules = {
    "/frontend/*" = "org/frontend-team"
    "/backend/*"  = "org/backend-team"
  }
}
```

## Generated CODEOWNERS File

```
# CODEOWNERS
# Automatically managed by Terraform.
# Global owners
* @org/admins
* @org/owners

# Additional ownership rules
/frontend/* @org/frontend-team
/backend/* @org/backend-team
```

## Inputs

| Name        | Description                    | Type           | Default  | Required |
| ----------- | ------------------------------ | -------------- | -------- | -------- |
| repository  | GitHub repository name         | `string`       | n/a      | yes      |
| branch      | Branch to create the file in   | `string`       | `"main"` | no       |
| admins      | List of admin usernames/teams  | `list(string)` | `[]`     | no       |
| owners      | List of owner usernames/teams  | `list(string)` | `[]`     | no       |
| extra_rules | Map of path patterns to owners | `map(string)`  | `{}`     | no       |

## Outputs

| Name            | Description                          |
| --------------- | ------------------------------------ |
| codeowners_file | The created CODEOWNERS file resource |
| all_owners      | List of all unique owners referenced |
