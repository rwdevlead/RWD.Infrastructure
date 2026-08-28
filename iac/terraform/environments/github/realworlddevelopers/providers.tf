terraform {
  cloud {
    organization = "realworlddevelopers"

    workspaces {
      project = "RWD Infrastructure"
      name    = "github-realworlddevelopers-repos"
    }
  }
  required_version = ">= 1.13.1"
  required_providers {
    infisical = {
      source  = "Infisical/infisical"
      version = "~> 0.14"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.1.0"
    }
  }
}

# --- Infisical provider ---
provider "infisical" {
  host = "https://app.infisical.com"
  auth = {
    universal = {
      client_id     = var.infisical_client_id
      client_secret = var.infisical_client_secret
    }
  }
}

# --- GitHub provider ---
provider "github" {
  token = local.github_token
  owner = local.github_owner
}

# https://registry.terraform.io/providers/Infisical/infisical/latest/docs#terraform
