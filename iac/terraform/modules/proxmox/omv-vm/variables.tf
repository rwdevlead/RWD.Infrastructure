variable "vm_name" {
  type        = string
  description = "Name of the OMV VM [default is 'omv']"
  default     = "omv"
}

variable "vm_description" {
  type        = string
  description = "Description of the VM [default is 'Virtual Machine']"
  default     = "Virtual Machine"
}

variable "vm_on_boot" {
  type        = bool
  description = "Start VM on Proxmox node boot"
}

variable "ssh_private_key_content" {
  description = "SSH private key content used by Terraform remote-exec to run qm set on the Proxmox host"
  type        = string
}

variable "proxmox_node_name" {
  type        = string
  description = "Target Proxmox node name"
}

variable "proxmox_node_ip" {
  type        = string
  description = "IP address of the target Proxmox node"
}

variable "vm_id" {
  type        = number
  description = "The VM ID for the OMV instance"
}

variable "vm_cores" {
  type        = number
  description = "Number of CPU cores for VM [default is 2]"
  default     = 2
}

variable "vm_machine" {
  type        = string
  description = "Machine type for VM (pc, q35) [default is q35]"
  default     = "q35"
}

variable "vm_bios" {
  type        = string
  description = "BIOS type for VM [default is ovmf]"
  default     = "ovmf"
}

variable "vm_memory_min" {
  type        = number
  description = "Minimum floating memory for VM in MiB [default is 8192]"
  default     = 8192
}

variable "vm_memory_max" {
  type        = number
  description = "Dedicated memory for VM in MiB [default is 8192]"
  default     = 8192
}

variable "boot_datastore" {
  type        = string
  description = "Storage location for the OS disk and EFI disk [default is local-lvm]"
  default     = "local-lvm"
}

variable "iso_file_id" {
  type        = string
  description = "The full path to the OMV ISO (e.g., local:iso/filename.iso) or 'none'"
}

variable "data_disk_id" {
  type        = string
  description = "The disk ID from /dev/disk/by-id/ for passthrough"
}

variable "disk_interface" {
  type        = string
  description = "Disk interface [default is virtio0]"
  default     = "virtio0"
}

variable "disk_size" {
  type        = number
  description = "Disk size in gigabytes [default is 32]"
  default     = 32
}

variable "vm_static_ip" {
  type        = string
  description = "Static IPv4 CIDR for VM [default is null]"
  default     = null
}

variable "network_gateway" {
  type        = string
  description = "Gateway IP for VM [default is dhcp]"
  default     = "dhcp"
}

variable "tags" {
  type        = set(string)
  description = "Tags assigned to the VM [default is ['omv']]"
  default     = ["omv"]
}
