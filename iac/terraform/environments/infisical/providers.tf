terraform {
  cloud {
    organization = "realworlddevelopers"

    workspaces {
      project = "RWD Infrastructure"
      name    = "infisical-testing"
    }
  }
  required_version = ">= 1.13.1"
  required_providers {
    infisical = {
      source  = "Infisical/infisical"
      version = "~> 0.14"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
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
