variable "proxmox_endpoint" {
  description = "Proxmox API endpoint (e.g., https://proxmox.local:8006/api2/json)"
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
  description = "Name of the new VM"
  type        = string
}

variable "vm_id" {
  description = "Optional VM ID (leave null for auto assignment)"
  type        = number
  default     = null
}

variable "cpu_cores" {
  description = "Number of CPU cores for the VM"
  type        = number
  default     = 2
}

variable "memory_mb" {
  description = "Amount of memory (in MB)"
  type        = number
  default     = 2048
}

variable "network_bridge" {
  description = "Network bridge (e.g., vmbr0)"
  type        = string
  default     = "vmbr0"
}

variable "qcow2_path" {
  description = "Path to the QCOW2 image file on the Proxmox node (e.g., /var/lib/vz/template/qcow2/myimage.qcow2)"
  type        = string
}

variable "storage_pool" {
  description = "Proxmox storage pool where the disk will be imported"
  type        = string
}

variable "disk_size_gb" {
  description = "Optional override for disk size (QCOW2 will be expanded if larger)"
  type        = number
  default     = 0
}

variable "bootdisk" {
  description = "Boot disk identifier (e.g., scsi0, sata0)"
  type        = string
  default     = "scsi0"
}

variable "start_on_boot" {
  description = "Whether the VM should start automatically after creation"
  type        = bool
  default     = true
}

variable "start_vm" {
  description = "Whether to power on the VM immediately"
  type        = bool
  default     = true
}
