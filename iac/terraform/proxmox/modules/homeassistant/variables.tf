variable "node_name" {
  type        = string
  description = "Name of the Node"
  # default     = "pve"
}

variable "vm_id" {
  type        = number
  description = "VM ID Number (Index)"
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

variable "vm_os" {
  type        = string
  description = "OS of Template [default is l26]"
  default     = "l26"
}

variable "vm_bios" {
  type        = string
  description = "Bios of Template [default is omvf]"
  default     = "ovmf"
}

variable "vm_machine" {
  type        = string
  description = "Machine Type of Template (pc, q35) [default is q35]"
  default     = "q35"
}

variable "vm_cores" {
  type        = number
  description = "Number of Cores for VM [default is 2]"
  default     = 2
}

variable "vm_memory" {
  type        = number
  description = "Memeory for Template [default is 4096]"
  default     = 4096
}

variable "efi_storage_id" {
  type        = string
  description = "Where to Put EFI Data [default is local-lvm]"
  default     = "local-lvm"
}

variable "disk_storage_id" {
  type        = string
  description = "Where to assign Drive to [default is local-lvm]"
  default     = "local-lvm"
}

variable "disk_interface" {
  type        = string
  description = "Disk Interface [default is virtio0]"
  default     = "virtio0"
}

variable "disk_size" {
  type        = number
  description = "Size of Disk (gigabytes)[default is 32 as per HAOS file specs]"
  default     = 32
}

variable "network_bridge" {
  type        = string
  description = "Name of Bridge on the Node to Use"
  # default = "vmbr0"
}

variable "tags" {
  type        = set(string)
  description = "tags for VM [default is 'vm']"
  default     = ["homeassistant"]
}


