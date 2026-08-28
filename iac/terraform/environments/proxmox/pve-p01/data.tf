# infisical secrets from vault
data "infisical_secrets" "proxmox" {
  env_slug     = "dev"
  folder_path  = "/terraform/proxmox/pve-p01"
  workspace_id = var.infisical_project_id
}
