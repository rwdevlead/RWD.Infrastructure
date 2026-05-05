
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

variable "PROVIDER_ENDPOINT" {}
variable "PROVIDER_API_TOKEN" {}
