variable "node_name" {
  type        = string
  description = "Target Proxmox node name"
}

variable "vm_id" {
  type        = number
  description = "VM ID number"
}

variable "vm_name" {
  type        = string
  description = "Name of the VM"
}

variable "vm_description" {
  type        = string
  description = "Description of the VM [default is 'Home Assistant Instance']"
  default     = "Home Assistant Instance"
}

variable "vm_on_boot" {
  type        = bool
  description = "Start VM on Proxmox node boot"
}

variable "vm_os" {
  type        = string
  description = "Guest OS type for VM [default is l26]"
  default     = "l26"
}

variable "vm_bios" {
  type        = string
  description = "BIOS type for VM [default is ovmf]"
  default     = "ovmf"
}

variable "vm_machine" {
  type        = string
  description = "Machine type for VM (pc, q35) [default is q35]"
  default     = "q35"
}

variable "vm_cores" {
  type        = number
  description = "Number of CPU cores for VM [default is 2]"
  default     = 2
}

variable "vm_memory" {
  type        = number
  description = "Memory for VM in MiB [default is 4096]"
  default     = 4096
}

variable "efi_storage_id" {
  type        = string
  description = "Datastore ID for EFI disk [default is local-lvm]"
  default     = "local-lvm"
}

variable "disk_storage_id" {
  type        = string
  description = "Datastore ID for VM disk [default is local-lvm]"
  default     = "local-lvm"
}

variable "disk_interface" {
  type        = string
  description = "Disk interface [default is virtio0]"
  default     = "virtio0"
}

variable "disk_size" {
  type        = number
  description = "Disk size in gigabytes [default is 32 per HAOS requirements]"
  default     = 32
}

variable "network_bridge" {
  type        = string
  description = "Network bridge on the Proxmox node"
}

variable "tags" {
  type        = set(string)
  description = "Tags assigned to the VM [default is ['homeassistant']]"
  default     = ["homeassistant"]
}
