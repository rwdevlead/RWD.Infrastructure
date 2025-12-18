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
  # using env endpoint  = var.virtual_environment_endpoint
  # using env api_token = var.virtual_environment_token
  insecure = true
  ssh {
    # agent       = true
    username    = "root"
    private_key = file("~/.ssh/id_ed25519")
  }
}

# provider "proxmox" {
#   # Adjust your URL, token, and user
#   pm_api_url = "https://192.168.50.11:8006/api2/json"
#   # pm_user         = "root@pam!rwd-iac"
#   # pm_password     = ""   # optional if using token
#   pm_tls_insecure = true # adjust for prod
# }

// TODO new provider
// https://registry.terraform.io/providers/bpg/proxmox/0.89.1


// https://registry.terraform.io/providers/Telmate/proxmox/latest/docs#creating-the-connection-via-username-and-api-token

// https://cloudinit.readthedocs.io/en/latest/reference/examples.html


