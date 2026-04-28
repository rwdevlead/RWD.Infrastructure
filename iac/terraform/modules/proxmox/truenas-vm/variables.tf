variable "vm_name" {
  type        = string
  description = "Name of the TrueNAS VM"
  default     = "truenas-scale"
}

variable "vm_description" {
  type        = string
  description = "Description of the VM [default is 'Virtual Machine']"
  default     = "Virtual Machine"
}

variable "ssh_private_key_content" {
  description = "The content of the SSH private key to inject into the VM. [default is ~/.ssh/id_ed25519]"
  type        = string
  # default     = file("~/.ssh/id_ed25519")
}

variable "proxmox_node_name" {
  type        = string
  description = "The Proxmox node to deploy to"
  default     = "proxmox"
}

variable "proxmox_node_ip" {
  type        = string
  description = "IP of Host Node"
  default     = null
}

variable "vm_id" {
  type        = number
  description = "The VM ID for the TrueNAS instance"
}

variable "vm_cores" {
  type    = number
  default = 2
}

variable "vm_machine" {
  type        = string
  description = "Machine Type of VM (pc, q35) [default is q35]"
  default     = "q35"
}

variable "vm_bios" {
  type        = string
  description = "Bios of VM [default is omvf]"
  default     = "ovmf"
}

variable "vm_memory_min" {
  type        = number
  description = "Memeory for Template [default is 2048]"
  default     = 8192
}

variable "vm_memory_max" {
  type        = number
  description = "Max memeory for VM [default is 0]"
  default     = 8192
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

variable "disk_interface" {
  type        = string
  description = "Disk Interface [default is virtio0]"
  default     = "virtio0"
}

variable "disk_size" {
  type        = number
  description = "Size of Disk (gigabytes)[default is 20]"
  default     = 32
}

variable "vm_static_ip" {
  type        = string
  description = "Static IP for VM [default is dhcp]"
  default     = null
}

variable "network_gateway" {
  type        = string
  description = "Gateway IP for VM"
  default     = "dhcp"
}

variable "tags" {
  type        = set(string)
  description = "tags for VM [default is 'vm']"
  default     = ["truenas"]
}
