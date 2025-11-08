terraform {
  cloud {
    organization = "realworlddevelopers"

    workspaces {
      project = "RWD Infrastructure"
      name    = "rwd-repositories"
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


# --- Primary GitHub provider ---
provider "github" {
  alias = "primary"
  token = var.github_token_primary
  owner = var.github_owner_primary
}

# --- Secondary GitHub provider (aliased) ---
provider "github" {
  alias = "organization"
  token = var.github_token_secondary
  owner = var.github_owner_secondary
}
