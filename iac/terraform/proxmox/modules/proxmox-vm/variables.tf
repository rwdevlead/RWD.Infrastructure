
variable "hostname" {
  type        = string
  description = "Hostname for the VM"
}

variable "node" {
  type        = string
  description = "Proxmox node to deploy the VM on"
}

variable "template_name" {
  type        = string
  description = "Name of the Proxmox template to clone"
}

variable "cpu_cores" {
  type        = number
  default     = 2
  description = "Number of CPU cores for the VM"
}

variable "memory_mb" {
  type        = number
  default     = 4096
  description = "Memory in MB for the VM"
}

variable "disk_size" {
  type        = string
  default     = "20G"
  description = "Disk size for the VM"
}

variable "ssh_public_key" {
  type        = string
  description = "Public SSH key for accessing VMs"
}

variable "bridge" {
  type        = string
  default     = "vmbr0"
  description = "Bridge for the VM network"
}

variable "ip_address" {
  description = "Static IP address for the VM"
  type        = string
}

variable "gateway" {
  description = "Gateway for the VM"
  type        = string
}

variable "netmask" {
  description = "CIDR netmask (e.g. 24)"
  type        = number
}

variable "vmid" {
  description = "VM Id to use (will use next in sequence if null)"
  type        = number
}
