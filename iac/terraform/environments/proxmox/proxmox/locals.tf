# short term vars to hold secrets
locals {
  PVE_TOKEN    = data.infisical_secrets.proxmox.secrets["PVE_TOKEN"].value
  PVE_ENDPOINT = data.infisical_secrets.proxmox.secrets["PVE_ENDPOINT"].value
}
