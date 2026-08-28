variable "infisical_client_id" {
  type      = string
  sensitive = true
}

variable "infisical_client_secret" {
  type      = string
  sensitive = true
}

variable "infisical_project_id" {
  type = string
}


variable "default_username" {
  type        = string
  description = "User for VM [default is null]"
  # default     = null
}

variable "default_password" {
  type        = string
  description = "Password Username [default is null]"
  #   default     = null
}

