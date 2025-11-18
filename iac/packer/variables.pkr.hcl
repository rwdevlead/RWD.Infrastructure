# variable "proxmox_url" {
#   type    = string
#   default = "https://proxmox.example.local:8006/api2/json"
# }

# variable "proxmox_user" {
#   type    = string
#   default = "root@pam"
# }

# variable "proxmox_token_id" {
#   type = string
# }

# variable "proxmox_token_secret" {
#   type = string
# }

# variable "template_name" {
#   type = string
# }

# variable "iso_file" {
#   type    = string
#   default = "local:iso/ubuntu-22.04.5-live-server-amd64.iso"
# }

# variable "vm_id" {
#   type = number
# }

# variable "ssh_username" {
#   type    = string
#   default = "ubuntu"
# }

# variable "ssh_public_key" {
#   type        = string
#   description = "Public SSH key for accessing VMs"
#   default     = file("~/.ssh/id_rsa.pub") # automatically load your local public key
# }