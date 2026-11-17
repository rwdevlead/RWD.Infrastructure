variable "node_name" {
  type        = string
  description = "Target Proxmox node name"
}

variable "template_mode" {
  type        = bool
  description = "Whether the VM is marked as a Proxmox template"
}

variable "vm_startup" {
  type        = bool
  description = "Start VM after creation"
}

variable "vm_id" {
  type        = number
  description = "Template VM ID number"
}

variable "vm_name" {
  type        = string
  description = "Name of the template VM [default is 'template']"
  default     = "template"
}

variable "vm_os" {
  type        = string
  description = "Guest OS type [default is l26]"
  default     = "l26"
}

variable "vm_bios" {
  type        = string
  description = "BIOS type for template [default is ovmf]"
  default     = "ovmf"
}

variable "vm_machine" {
  type        = string
  description = "Machine type for template (pc, q35) [default is q35]"
  default     = "q35"
}

variable "vm_cores" {
  type        = number
  description = "Number of CPU cores for template [default is 2]"
  default     = 2
}

variable "vm_memory" {
  type        = number
  description = "Memory for template in MiB [default is 2048]"
  default     = 2048
}

variable "efi_storage_id" {
  type        = string
  description = "Datastore ID for EFI disk"
}

variable "disk_storage_id" {
  type        = string
  description = "Datastore ID for primary template disk"
}

variable "disk_interface" {
  type        = string
  description = "Disk interface (e.g., virtio0)"
}

variable "disk_size" {
  type        = number
  description = "Disk size in gigabytes [default is 20]"
  default     = 20
}

variable "network_bridge" {
  type        = string
  description = "Network bridge on the Proxmox node"
}

variable "iso_file" {
  type        = string
  description = "Legacy ISO file ID reference [default is iso-images:iso/ubuntu-24.04-live-server-amd64.iso]"
  default     = "iso-images:iso/ubuntu-24.04-live-server-amd64.iso"
}

variable "iso_checksum" {
  type        = string
  description = "Checksum for download validation"
}

variable "iso_checksum_algorithm" {
  type        = string
  description = "Hash algorithm for ISO checksum validation"
}

variable "iso_url" {
  type        = string
  description = "URL to download cloud image"
}

variable "iso_target" {
  type        = string
  description = "Datastore ID where downloaded image is stored"
}

variable "image_file_name" {
  description = "File name of the downloaded cloud image [default is noble-server-cloudimg-amd64.img]"
  type        = string
  default     = "noble-server-cloudimg-amd64.img"
}

variable "img_file_path" {
  description = "Absolute path on Proxmox host where image files are stored [default is /var/lib/vz/template/iso]"
  type        = string
  default     = "/var/lib/vz/template/iso"
}

variable "tags" {
  type        = set(string)
  default     = ["template"]
  description = "Tags assigned to the template [default is ['template']]"
}

variable "ssh_public_key_content" {
  description = "SSH public key content injected into the template via cloud-init"
  type        = string
}
