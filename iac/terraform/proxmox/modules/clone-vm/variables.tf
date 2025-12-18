
variable "keyboard" {
  type        = string
  description = "Keyboard Layout [default is en-us]"
  default     = "en-us"
}

variable "tempate_node_id" {
  type        = number
  description = "Name of the Node (server)"
}

variable "tempate_node_name" {
  type        = string
  description = "Name of the Node (server)"
}

variable "vm_node_name" {
  type        = string
  description = "Name of the Node (server)"
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
  description = "Description of the VM [default is 'Virtual Machine']"
  default     = "Virtual Machine"
}

variable "vm_username" {
  type        = string
  description = "User for VM [default is null]"
  # default     = null
}

variable "vm_password" {
  type        = string
  description = "Password Username [default is null]"
  # default     = null
}

variable "ssh_public_key" {
  description = "The content of the SSH public key to inject into the VM. [default is ~/.ssh/id_ed25519.pub]"
  type        = string
  # default     = file("~/.ssh/id_ed25519.pub")
}

variable "vm_os" {
  type        = string
  description = "OS of VM [default is l26]"
  default     = "l26"
}

variable "vm_bios" {
  type        = string
  description = "Bios of VM [default is omvf]"
  default     = "ovmf"
}

variable "efi_storage_id" {
  type        = string
  description = "Where to Put EFI Data [default is local-lvm]"
  default     = "local-lvm"
}

variable "vm_machine" {
  type        = string
  description = "Machine Type of VM (pc, q35) [default is q35]"
  default     = "q35"
}

variable "vm_cores" {
  type        = number
  description = "Number of Cores for VM [default is 2]"
  default     = 2
}

variable "vm_memory_min" {
  type        = number
  description = "Memeory for Template [default is 2048]"
  default     = 2048
}

variable "vm_memory_max" {
  type        = number
  description = "Max memeory for VM [default is 0]"
  default     = 0
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
  description = "Size of Disk (gigabytes)[default is 20]"
  default     = 20
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

variable "network_device_model" {
  type        = string
  description = "Model of Device on the Network [default is virtio]"
  default     = "virtio"
}

variable "tags" {
  type        = set(string)
  description = "tags for VM [default is 'vm']"
  default     = ["vm"]
}


