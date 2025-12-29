# GitHub Teams Module

This Terraform module creates GitHub teams and manages team memberships.

## Features

- Creates multiple teams with descriptions
- Manages team memberships
- Supports bulk team creation

## Usage

```hcl
module "teams" {
  source = "./modules/github-teams"

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

| Name  | Description                            | Type                                                            | Default | Required |
| ----- | -------------------------------------- | --------------------------------------------------------------- | ------- | -------- |
| teams | Map of teams with their configurations | `map(object({ description = string, members = list(string) }))` | n/a     | yes      |

## Outputs

| Name        | Description                 |
| ----------- | --------------------------- |
| teams       | Map of created GitHub teams |
| memberships | Map of team memberships     |
