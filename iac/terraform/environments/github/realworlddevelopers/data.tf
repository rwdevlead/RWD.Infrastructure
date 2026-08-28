# infisical secrets from vault
data "infisical_secrets" "github" {
  env_slug     = "dev"
  folder_path  = "/terraform/github/realworlddevelopers"
  workspace_id = var.infisical_project_id
}
