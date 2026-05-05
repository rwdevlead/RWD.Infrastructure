variable "github_token_realworlddevelopers" {
  description = "GitHub token for the secondary organization."
  type        = string
  sensitive   = true
  default     = null
}

variable "github_owner_realworlddevelopers" {
  description = "Owner or organization name for the secondary GitHub provider."
  type        = string
  default     = null
}

variable "github_actor_id_realworlddevelopers" {
  description = "Actor Id for the secondary GitHub provider."
  type        = number
  default     = null
}
