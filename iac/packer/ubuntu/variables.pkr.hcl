variable "proxmox_url" {
  type    = string
  default = "https://proxmox.example2.local:8006/api2/json"
}

variable "username" {
  type    = string
  default = ""
  // Sensitive vars are hidden from output as of Packer v1.6.5
  sensitive = true
}
variable "token" {
  type    = string
  default = ""
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
  default   = ""
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
  default = null
}

variable "iso_checksum" {
  type    = string
  default = null
}

variable "iso_url" {
  type    = string
  default = null
}



