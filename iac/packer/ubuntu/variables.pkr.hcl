variable "proxmox_url" {
  type    = string
  default = "https://proxmox.example2.local:8006/api2/json"
}

variable "username" {
  type    = string
  default = "root@pam!rwd-iac"
  // Sensitive vars are hidden from output as of Packer v1.6.5
  sensitive = true
}
variable "token" {
  type    = string
  default = "ff2fcab2-fad4-448b-811d-56bf3b5b609f"
  // Sensitive vars are hidden from output as of Packer v1.6.5
  sensitive = true
}
variable "ssh_username" {
  type    = string
  default = "root"
  // Sensitive vars are hidden from output as of Packer v1.6.5
  sensitive = true
}

variable "ssh_pub_key" {
  type      = string
  default   = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIYOURPUBLICKEYHERE user@host"
  sensitive = true
}

variable "node" {
  type    = string
  default = "pve"
}

variable "vm_id" {
  type    = number
  default = 9000
}

variable "template_name" {
  type    = string
  default = "ubuntu-24.04-template"
}

variable "iso_file" {
  type    = string
  default = "local:iso/ubuntu-22.04.5-live-server-amd64.iso"
}

