# ==========================================================
# Normal Ubuntu VM (no Docker)
# ==========================================================
# module "Dev_Ubuntu" {
#   source         = "./modules/proxmox-vm"
#   providers      = { proxmox = proxmox }
#   hostname       = "ubuntu-vm01"
#   vmid           = 102
#   node           = "proxmox"
#   template_name  = "ubuntu-24.04-template"
#   cpu_cores      = 2
#   memory_mb      = 4096
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
#   vmid           = 101
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
