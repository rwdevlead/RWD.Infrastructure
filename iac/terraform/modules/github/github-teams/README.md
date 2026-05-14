# GitHub Teams Module

This Terraform module creates GitHub teams and manages team memberships.

## Features

- Creates multiple teams with descriptions
- Manages team memberships using `for_each` for scalability
- Returns team slugs and IDs for integration with other modules
- Supports bulk team creation and member management

## Usage

```hcl
module "teams" {
  source = "./modules/github-teams"

  github_owner = "my-organization"

  teams = {
    "admins" = {
      description = "Repository administrators"
      members     = ["user1", "user2"]
    }
    "developers" = {
      description = "Development team"
      members     = ["user3", "user4", "user5"]
    }
  }
}
```

## Inputs

| Name         | Description                              | Type                                                            | Default | Required |
| ------------ | ---------------------------------------- | --------------------------------------------------------------- | ------- | -------- |
| github_owner | GitHub organization or user owning teams | `string`                                                        | n/a     | yes      |
| teams        | Map of teams with configurations         | `map(object({ description = string, members = list(string) }))` | n/a     | yes      |

## Outputs

| Name       | Description                    |
| ---------- | ------------------------------ |
| team_slugs | Map of team slugs by team name |
| team_ids   | Map of team IDs by team name   |
