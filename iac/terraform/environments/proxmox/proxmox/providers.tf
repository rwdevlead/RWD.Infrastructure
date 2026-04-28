# ==========================================================
# Proxmox provider
# ==========================================================
terraform {
  required_version = ">= 1.13.1"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.89.1" # version = ">=0.66"
    }
  }
}

provider "proxmox" {
  endpoint  = var.PROVIDER_ENDPOINT
  api_token = var.PROVIDER_API_TOKEN
  insecure  = true
  ssh {
    # agent       = true
    username    = "root"
    private_key = file("~/.ssh/id_ed25519")
  }
}


// provider
// https://registry.terraform.io/providers/bpg/proxmox/0.89.1

