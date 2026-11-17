variable "keyboard" {
  type        = string
  description = "Keyboard layout [default is en-us]"
  default     = "en-us"
}

variable "tempate_node_id" {
  type        = number
  description = "Source template VM ID to clone"
}

variable "tempate_node_name" {
  type        = string
  description = "Proxmox node hosting the source template"
}

variable "vm_node_name" {
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
  description = "Description of the VM [default is 'Virtual Machine']"
  default     = "Virtual Machine"
}

variable "vm_on_boot" {
  type        = bool
  description = "Start VM on Proxmox node boot"
}

variable "vm_username" {
  type        = string
  description = "Username input for VM configuration"
}

variable "vm_password" {
  type        = string
  description = "Password input for VM configuration"
}

variable "ssh_public_key_content" {
  description = "SSH public key content injected into the VM via cloud-init"
  type        = string
}

variable "vm_os" {
  type        = string
  description = "Guest OS type [default is l26]"
  default     = "l26"
}

variable "vm_bios" {
  type        = string
  description = "BIOS type for VM [default is ovmf]"
  default     = "ovmf"
}

variable "efi_storage_id" {
  type        = string
  description = "Datastore ID for EFI disk [default is local-lvm]"
  default     = "local-lvm"
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

variable "vm_memory_min" {
  type        = number
  description = "Minimum floating memory for VM in MiB [default is 2048]"
  default     = 2048
}

variable "vm_memory_max" {
  type        = number
  description = "Dedicated memory for VM in MiB [default is 0]"
  default     = 0
}

variable "disk_storage_id" {
  type        = string
  description = "Datastore ID for primary VM disk [default is local-lvm]"
  default     = "local-lvm"
}

variable "disk_interface" {
  type        = string
  description = "Disk interface [default is virtio0]"
  default     = "virtio0"
}

variable "disk_size" {
  type        = number
  description = "Disk size in gigabytes [default is 20]"
  default     = 20
}

variable "vm_static_ip" {
  type        = string
  description = "Static IPv4 CIDR for VM (null uses no static IP) [default is null]"
  default     = null
}

variable "network_gateway" {
  type        = string
  description = "Gateway IP for VM [default is dhcp]"
  default     = "dhcp"
}

variable "network_device_model" {
  type        = string
  description = "Virtual network device model [default is virtio]"
  default     = "virtio"
}

variable "tags" {
  type        = set(string)
  description = "Tags assigned to the VM [default is ['vm']]"
  default     = ["vm"]
}
