variable "github_token_primary" {
  description = "GitHub token for the primary organization."
  type        = string
  sensitive   = true
}

variable "github_owner_primary" {
  description = "Owner or organization name for the primary GitHub provider."
  type        = string
}

variable "github_token_secondary" {
  description = "GitHub token for the secondary organization."
  type        = string
  sensitive   = true
  default     = null
}

variable "github_owner_secondary" {
  description = "Owner or organization name for the secondary GitHub provider."
  type        = string
  default     = null
}


variable "github_actor_id_primary" {
  description = "Actor Id for the primary GitHub provider."
  type        = number
  default     = null
}

variable "github_actor_id_secondary" {
  description = "Actor Id for the secondary GitHub provider."
  type        = number
  default     = null
}
