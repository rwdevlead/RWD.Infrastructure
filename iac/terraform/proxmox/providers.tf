# ==========================================================
# Proxmox provider
# ==========================================================
provider "proxmox" {
  # Adjust your URL, token, and user
  pm_api_url      = "https://proxmox.example.local:8006/api2/json"
  pm_user         = "root@pam!rwd-iac"
  pm_password     = ""   # optional if using token
  pm_tls_insecure = true # adjust for prod
  pm_token_id     = "packer@pve!tokenid"
  pm_token_secret = var.proxmox_token_secret
}
