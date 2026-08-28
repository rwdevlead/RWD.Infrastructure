# ==========================================================
# Proxmox provider
# ==========================================================
terraform {
  required_version = ">= 1.13.1"

  cloud {
    organization = "realworlddevelopers"

    workspaces {
      name    = "proxmox-pve-d01"
      project = "RWD Infrastructure"
    }
  }

  required_providers {
    infisical = {
      source  = "Infisical/infisical"
      version = "~> 0.14"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.89.1" # version = ">=0.66"
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

provider "proxmox" {
  endpoint  = local.PVE_ENDPOINT
  api_token = local.PVE_TOKEN
  insecure  = true
  ssh {
    # agent       = true
    username    = "root"
    private_key = file("~/.ssh/id_ed25519")
  }
}

# provider
# https://registry.terraform.io/providers/bpg/proxmox/0.89.1
# https://registry.terraform.io/providers/Infisical/infisical/latest/docs#terraform

