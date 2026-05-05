terraform {
  cloud {
    organization = "realworlddevelopers"

    workspaces {
      project = "RWD Infrastructure"
      name    = "github-rwdevlead-repos"
    }
  }
  required_version = ">= 1.13.1"
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.1.0"
    }
  }
}

# --- GitHub provider ---
provider "github" {
  token = var.github_token_rwdevlead
  owner = var.github_owner_rwdevlead
}
