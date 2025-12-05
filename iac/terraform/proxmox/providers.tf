# ==========================================================
# Proxmox provider
# ==========================================================
terraform {
  required_version = ">= 1.13.1"
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc06"
    }
  }
}

provider "proxmox" {
  # Adjust your URL, token, and user
  pm_api_url = "https://192.168.50.11:8006/api2/json"
  # pm_user         = "root@pam!rwd-iac"
  # pm_password     = ""   # optional if using token
  pm_tls_insecure = true # adjust for prod
}

// https://registry.terraform.io/providers/Telmate/proxmox/latest/docs#creating-the-connection-via-username-and-api-token
// TODO need to pass token secrets same as packer / github uses

// https://cloudinit.readthedocs.io/en/latest/reference/examples.html
