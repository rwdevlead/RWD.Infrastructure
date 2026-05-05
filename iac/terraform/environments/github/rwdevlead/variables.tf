variable "github_token_rwdevlead" {
  description = "GitHub token for the primary organization."
  type        = string
  sensitive   = true
}

variable "github_owner_rwdevlead" {
  description = "Owner or organization name for the primary GitHub provider."
  type        = string
}

variable "github_actor_id_rwdevlead" {
  description = "Actor Id for the primary GitHub provider."
  type        = number
  default     = null
}
