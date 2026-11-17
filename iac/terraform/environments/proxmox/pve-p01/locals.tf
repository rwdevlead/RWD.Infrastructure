# short term vars to hold secrets and shared infrastructure config
locals {
  PVE_TOKEN    = data.infisical_secrets.proxmox.secrets["PVE_TOKEN"].value
  PVE_ENDPOINT = data.infisical_secrets.proxmox.secrets["PVE_ENDPOINT"].value
  infra        = yamldecode(file("${path.module}/../../../../shared/infrastructure.yml"))
}
