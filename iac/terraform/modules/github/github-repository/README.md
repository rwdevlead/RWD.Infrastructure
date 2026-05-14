# GitHub Repository Module

This Terraform module creates and manages GitHub repositories with configurable settings.

## Features

- Creates public, private, or internal repositories
- Configures repository settings (issues, projects, wiki, discussions)
- Enables vulnerability alerts by default
- Auto-deletes head branches on merge
- Disables archive on destroy to prevent accidental deletion
- Supports topics and descriptions

## Usage

```hcl
module "my_repo" {
  source = "./modules/github-repository"

  repository_name = "my-repo"
  description     = "A sample repository"
  visibility      = "private"

  topics          = ["terraform", "infrastructure"]
  has_issues      = true
  has_projects    = false
  has_wiki        = false
  has_discussions = true
  auto_init       = true
}
```

## Inputs

| Name              | Description                                       | Type           | Default     | Required |
| ----------------- | ------------------------------------------------- | -------------- | ----------- | -------- |
| repository_name   | Name of the GitHub repository                     | `string`       | n/a         | yes      |
| description       | Repository description                            | `string`       | `""`        | no       |
| visibility        | Repository visibility (public, private, internal) | `string`       | `"private"` | no       |
| topics            | List of repository topics                         | `list(string)` | `[]`        | no       |
| has_issues        | Enable issues                                     | `bool`         | `true`      | no       |
| has_projects      | Enable projects                                   | `bool`         | `false`     | no       |
| has_wiki          | Enable wiki                                       | `bool`         | `false`     | no       |
| has_discussions   | Enable discussions                                | `bool`         | `false`     | no       |
| auto_init         | Initialize with README                            | `bool`         | `true`      | no       |
| teams             | Map of team slugs to permissions (optional)       | `map(string)`  | `{}`        | no       |
| external_team_ids | Map of external team IDs by name (optional)       | `map(string)`  | `{}`        | no       |

## Outputs

| Name            | Description                    |
| --------------- | ------------------------------ |
| repository_id   | The GitHub repository node ID  |
| repository_url  | The HTML URL of the repository |
| repository_name | The repository name            |
