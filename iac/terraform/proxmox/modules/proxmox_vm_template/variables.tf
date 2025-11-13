variable "proxmox_endpoint" {
  description = "Proxmox API endpoint (e.g. https://proxmox.local:8006/api2/json)"
  type        = string
}

variable "proxmox_token_id" {
  description = "Proxmox API token ID"
  type        = string
  sensitive   = true
}

variable "proxmox_token_secret" {
  description = "Proxmox API token secret"
  type        = string
  sensitive   = true
}

variable "node_name" {
  description = "Proxmox node name where the VM will be created"
  type        = string
}

variable "vm_name" {
  description = "Name of the new virtual machine"
  type        = string
}

variable "vm_id" {
  description = "Optional explicit VM ID"
  type        = number
  default     = null
}

variable "clone_template" {
  description = "Name of the Proxmox template to clone"
  type        = string
}

variable "cpu_cores" {
  description = "Number of CPU cores for the VM"
  type        = number
  default     = 2
}

variable "memory_mb" {
  description = "RAM size in MB"
  type        = number
  default     = 2048
}

variable "disk_size_gb" {
  description = "Disk size in GB"
  type        = number
  default     = 10
}

variable "storage_pool" {
  description = "Proxmox storage pool for the disk"
  type        = string
}

variable "network_bridge" {
  description = "Proxmox network bridge to attach (e.g., vmbr0)"
  type        = string
  default     = "vmbr0"
}

variable "ip_address" {
  description = "Static IP address with CIDR (e.g., 192.168.1.50/24). Leave empty for DHCP."
  type        = string
  default     = ""
}

variable "gateway" {
  description = "Default gateway for the VM (optional)"
  type        = string
  default     = ""
}

variable "ssh_public_key" {
  description = "SSH public key to inject into the VM via cloud-init"
  type        = string
  default     = ""
}
