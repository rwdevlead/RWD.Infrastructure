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
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.89.1" # version = ">=0.66"
    }
  }
}

provider "proxmox" {
  endpoint  = var.PVE_D01_ENDPOINT
  api_token = var.PVE_D01_TERRAFORM_TOKEN
  insecure  = true
  ssh {
    # agent       = true
    username    = "root"
    private_key = file("~/.ssh/id_ed25519")
  }
}

// provider
// https://registry.terraform.io/providers/bpg/proxmox/0.89.1
