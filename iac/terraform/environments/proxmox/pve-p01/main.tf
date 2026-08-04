
# commented out to use default values

locals {
  # trimspace removes trailing newlines that cause perpetual drift in some providers
  ssh_public_key_content  = trimspace(file("~/.ssh/id_ed25519.pub"))
  ssh_private_key_content = file("~/.ssh/id_ed25519")
}

module "ubuntu_template" {
  source        = "../../../modules/proxmox/template-ubuntu"
  vm_id         = 801
  vm_name       = "ubuntu-2404-template"
  node_name     = "pve-p01"
  template_mode = true
  vm_startup    = false

  efi_storage_id = "local-lvm"
  vm_bios        = "ovmf"
  #   vm_cores       
  vm_machine = "q35"
  vm_memory  = 4096
  vm_os      = "l26"

  network_bridge = "vmbr0"

  disk_size       = 20
  disk_interface  = "virtio0"
  disk_storage_id = "local-lvm"

  iso_target   = "local"
  iso_checksum = "d8f7f427a53c221feee90d47ca008d89237e206a2d4935c98b84eefdbf52f41d"
  iso_url      = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
  #   iso_file               = "iso-images:iso/ubuntu-24.04-live-server-amd64.iso"
  iso_checksum_algorithm = "sha256"

  tags = ["template", "linux"]

  ssh_public_key_content = local.ssh_public_key_content

}

module "Prod_Docker_01" {
  source = "../../../modules/proxmox/clone-vm"

  tempate_node_id   = module.ubuntu_template.template_id
  tempate_node_name = module.ubuntu_template.template_node_name

  vm_id          = 101
  vm_node_name   = "pve-p01"
  vm_name        = "prod-docker-01"
  vm_description = "Production Docker Instance"
  #   keyboard      

  vm_username = var.default_username
  vm_password = var.default_password

  vm_cores = 2

  efi_storage_id = "local-lvm"
  vm_os          = "l26"
  vm_bios        = "ovmf"
  vm_machine     = "q35"

  vm_memory_max = 8192
  vm_memory_min = 4096

  disk_interface  = "virtio0"
  disk_size       = 40
  disk_storage_id = "local-lvm"

  network_gateway      = "192.168.50.1"
  vm_static_ip         = "192.168.50.14/24"
  network_device_model = "virtio"

  tags = ["vm", "prod", "docker"]

  ssh_public_key_content = local.ssh_public_key_content

}

module "omv_vm" {
  source            = "../../../modules/proxmox/omv-vm"
  vm_name           = "dev-omv-01"
  vm_id             = 102
  vm_description    = "Open Media Vault - Managed by Terraform"
  proxmox_node_name = "pve-p01"
  proxmox_node_ip   = "192.168.50.10"

  # Resource Allocation
  vm_cores = 2

  vm_bios    = "ovmf"
  vm_machine = "q35"

  vm_memory_max = 4096 # 3-4 gig 3073-4096
  vm_memory_min = 4096

  # Storage & Media
  boot_datastore = "local-lvm"
  # iso_file_id    = "local:iso/openmediavault_8.3.1-amd64.iso"
  iso_file_id = "none"

  # Physical Disk Passthrough
  data_disk_id   = "ata-HGST_HTS541010A9E680_JA1009C033492P"
  disk_interface = "scsi0"
  disk_size      = 32

  network_gateway = "192.168.50.1"
  vm_static_ip    = "192.168.50.17/24"

  tags = ["vm", "dev", "omv", "storage"]

  ssh_private_key_content = local.ssh_private_key_content

}
