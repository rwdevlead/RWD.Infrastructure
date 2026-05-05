# GitHub Repository Module

This Terraform module creates and manages GitHub repositories with configurable settings.

## Features

- Creates public or private repositories
- Configures repository settings (issues, projects, wiki, discussions)
- Enables vulnerability alerts and auto-merge on branch deletion
- Supports topics and descriptions

## Usage

```hcl
module "repository" {
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

| Name            | Description                            | Type           | Default     | Required |
| --------------- | -------------------------------------- | -------------- | ----------- | -------- |
| repository_name | Name of the repository                 | `string`       | n/a         | yes      |
| description     | Repository description                 | `string`       | n/a         | yes      |
| visibility      | Repository visibility (public/private) | `string`       | `"private"` | no       |
| topics          | List of repository topics              | `list(string)` | `[]`        | no       |
| has_issues      | Enable issues                          | `bool`         | `true`      | no       |
| has_projects    | Enable projects                        | `bool`         | `true`      | no       |
| has_wiki        | Enable wiki                            | `bool`         | `true`      | no       |
| has_discussions | Enable discussions                     | `bool`         | `false`     | no       |
| auto_init       | Initialize with README                 | `bool`         | `false`     | no       |

## Outputs

| Name       | Description                   |
| ---------- | ----------------------------- |
| repository | The created GitHub repository |
