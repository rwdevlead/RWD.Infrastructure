
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

variable "PVE_D01_ENDPOINT" {}
variable "PVE_D01_TERRAFORM_TOKEN" {}

