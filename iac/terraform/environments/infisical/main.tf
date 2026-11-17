data "infisical_secrets" "github" {
  env_slug     = "dev"
  folder_path  = "/terraform/github"
  workspace_id = var.infisical_project_id
}

# Marked sensitive so Infisical values are redacted in plan/apply logs
output "mail_user_preview" {
  description = "GitHub owner secret fetched from Infisical for integration smoke testing"
  value       = data.infisical_secrets.github.secrets["TF_VAR_github_owner_rwdevlead"].value
  sensitive   = true
}

resource "local_file" "test_env" {
  filename = "${path.module}/.env.test"
  content  = <<-EOT
    TF_VAR_github_owner_rwdevlead=${data.infisical_secrets.github.secrets["TF_VAR_github_owner_rwdevlead"].value}
  EOT
}
