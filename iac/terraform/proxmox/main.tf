
# commented out to use default values

locals {
  # Read the content of the key for direct injection (still the most effective method)
  ssh_public_key_content  = file("~/.ssh/id_ed25519.pub")
  ssh_private_key_content = file("~/.ssh/id_ed25519")
}

module "ubuntu_template" {
  source    = "./modules/template-ubuntu"
  vm_id     = 901
  vm_name   = "ubuntu-2404-template"
  node_name = "proxmox"

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

  ssh_public_key_content  = local.ssh_public_key_content
  ssh_private_key_content = local.ssh_private_key_content

}

# module "Dev_Docker" {
#   source = "./modules/clone-vm"

#   tempate_node_id   = module.ubuntu_template.template_id
#   tempate_node_name = module.ubuntu_template.template_node_name

#   vm_id          = 101
#   vm_node_name   = "proxmox"
#   vm_name        = "Docker-vm01"
#   vm_description = "Development Docker Instand"
#   #   keyboard      

#   vm_username = "ka8kgj"
#   vm_password = "password123"

#   vm_cores = 2

#   efi_storage_id = "local-lvm"
#   vm_os          = "l26"
#   vm_bios        = "ovmf"
#   vm_machine     = "q35"

#   vm_memory_max = 8192
#   vm_memory_min = 4096

#   disk_interface  = "virtio0"
#   disk_size       = 20
#   disk_storage_id = "local-lvm"

#   network_gateway      = "192.168.50.1"
#   vm_static_ip         = "192.168.50.14/24"
#   network_device_model = "virtio"

#   tags = ["vm", "dev", "docker"]

#   ssh_public_key = local.ssh_key_content

# }

# module "homeassistant" {
#   source    = "./modules/homeassistant"
#   vm_id     = 102
#   name      = "homeassistant"
#   node      = var.pm_node
#   qcow2_url = "https://github.com/home-assistant/operating-system/releases/latest/download/haos_ova-12.4.qcow2.xz"
#   storage   = "local-lvm"
# }


# ==========================================================
# Normal Ubuntu VM (no Docker)
# ==========================================================
# module "Dev_Ubuntu" {
#   source         = "./modules/proxmox-vm"
#   providers      = { proxmox = proxmox }
#   hostname       = "ubuntu-vm01"
#   vmid           = 101
#   node           = "proxmox"
#   template_name  = "ubuntu-24.04-template"
#   cpu_cores      = 2
#   memory_min_mb  = 4096
#   memory_max_mb  = 8192
#   disk_size      = "20G"
#   ssh_public_key = file("~/.ssh/id_ed25519.pub")
#   ip_address     = "192.168.50.14"
#   gateway        = "192.168.50.1"
#   netmask        = 24
# }


# ==========================================================
# Docker-enabled Ubuntu VM
# ==========================================================
# module "Dev_Docker" {
#   source         = "./modules/proxmox-vm-docker"
#   providers      = { proxmox = proxmox }
#   hostname       = "docker-vm01"
#   vmid           = 102
#   node           = "proxmox"
#   template_name  = "ubuntu-24.04-template"
#   cpu_cores      = 2
#   memory_mb      = 4096
#   disk_size      = "20G"
#   ssh_public_key = file("~/.ssh/id_ed25519.pub")
#   ip_address     = "192.168.50.13"
#   gateway        = "192.168.50.1"
#   netmask        = 24
# }
