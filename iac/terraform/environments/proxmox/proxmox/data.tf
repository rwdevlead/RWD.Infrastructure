data "infisical_secrets" "proxmox" {
  env_slug     = "dev"
  folder_path  = "/terraform/proxmox/tower"
  workspace_id = var.infisical_project_id
}
