locals {
  PVE_TOKEN    = data.infisical_secrets.proxmox.secrets["PVE_TOKEN"].value
  PVE_ENDPOINT = data.infisical_secrets.proxmox.secrets["PVE_ENDPOINT"].value
  # Load single-source-of-truth topology shared with Ansible inventories
  infra = yamldecode(file("${path.module}/../../../../shared/infrastructure.yml"))
}
