variable "node_name" {
  type        = string
  description = "Name of the Node (server)"
  # default = "pve"
}
variable "vm_id" {
  type        = number
  description = "Template ID Number (Index)"
}
variable "vm_name" {
  type        = string
  description = "Name of the Template"
  default     = "template"
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
  description = "Memeory for Template [default is 2048]"
  default     = 2048
}

variable "efi_storage_id" {
  type        = string
  description = "Where to Put EFI Data"
  # default = "local-lvm"
}

variable "disk_storage_id" {
  type        = string
  description = "Where to assign Drive to"
  # default = "local-lvm"
}
variable "disk_interface" {
  type        = string
  description = "Disk Interface"
  # default = "virtio0"
}
variable "disk_size" {
  type        = number
  description = "Size of Disk (gigabytes)[default is 20]"
  default     = 20
}
variable "network_bridge" {
  type        = string
  description = "Name of Bridge on the Node to Use"
  # default = "vmbr0"
}

variable "iso_file" {
  type        = string
  description = ""
  default     = "iso-images:iso/ubuntu-24.04-live-server-amd64.iso"
}
variable "iso_checksum" {
  type        = string
  description = "Checksum for Validation of Download"
  # default = "file:https://cloud-images.ubuntu.com/noble/current/SHA256SUMS"
}
variable "iso_checksum_algorithm" {
  type        = string
  description = "Hash to Validate With"
  # default = "sha256"
}
variable "iso_url" {
  type        = string
  description = "URL to Download Image"
  # default = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
}
variable "iso_target" {
  type        = string
  description = "Where to Store File on Template"
  # default = "sha256"
}


variable "image_file_name" {
  description = "The file name of the downloaded cloud image (e.g., ubuntu-2404-cloudimg-amd64.img)"
  type        = string
  # TODO no default setting
  default = "noble-server-cloudimg-amd64.img"
}

variable "img_file_path" {
  description = "The absolute path on the Proxmox host where the image file is located, based on the storage convention."
  type        = string
  # Assuming 'var.iso_target' is 'local' (where vz/template/raw resides) 
  # and assuming you corrected the content_type to 'vztmpl' or similar.
  # This path is the most common default for templates/raw images.
  # TODO no default setting
  default = "/var/lib/vz/template/iso"
}


variable "tags" {
  type        = set(string)
  default     = ["template"]
  description = "tags for VM [default is 'template']"
}


variable "ssh_private_key_content" {
  description = "The content of the SSH private key to inject into the VM. [default is null]"
  type        = string
  # default     = null
}

variable "ssh_public_key_content" {
  description = "The content of the SSH public key to inject into the VM. [default is null]"
  type        = string
  # default     = null
}
