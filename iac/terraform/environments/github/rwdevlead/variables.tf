variable "infisical_client_id" {
  type        = string
  description = "Infisical Universal Auth client ID"
  sensitive   = true
}

variable "infisical_client_secret" {
  type        = string
  description = "Infisical Universal Auth client secret"
  sensitive   = true
}

variable "infisical_project_id" {
  type        = string
  description = "Target Infisical project ID"
}
