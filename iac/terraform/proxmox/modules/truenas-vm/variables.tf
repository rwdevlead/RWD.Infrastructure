variable "vm_name" {
  type        = string
  description = "Name of the TrueNAS VM"
  default     = "truenas-scale"
}

variable "proxmox_node" {
  type        = string
  description = "The Proxmox node to deploy to"
  default     = "proxmox"
}

variable "vm_id" {
  type        = number
  description = "The VM ID for the TrueNAS instance"
}

variable "cpu_cores" {
  type    = number
  default = 2
}

variable "memory_mb" {
  type    = number
  default = 8192
}

variable "boot_datastore" {
  type        = string
  description = "Storage location for the OS disk and EFI disk"
  default     = "local-lvm"
}

variable "iso_file_id" {
  type        = string
  description = "The full path to the TrueNAS ISO (e.g., local:iso/filename.iso)"
}

variable "data_disk_id" {
  type        = string
  description = "The disk ID from /dev/disk/by-id/ for passthrough"
}

variable "tags" {
  type        = set(string)
  description = "tags for VM [default is 'vm']"
  default     = ["truenas"]
}
