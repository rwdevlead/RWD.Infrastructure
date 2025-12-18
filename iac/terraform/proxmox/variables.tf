
# variable "pm_api_url" {}
# variable "pm_api_token" {}

# variable "pm_node" {
#   default = "pve"
# }

# variable "ssh_public_key" {}

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

# variable "ssh_public_key" {
#   description = "The content of the SSH public key to inject into the VM. [default is ~/.ssh/id_ed25519.pub]"
#   type        = string
#   #   default     = file("~/.ssh/id_ed25519.pub")
# }
