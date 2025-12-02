





# ==========================================================
# Normal Ubuntu VM (no Docker)
# ==========================================================
module "my_vm" {
  source         = "./modules/proxmox-vm"
  hostname       = "ubuntu-vm01"
  node           = "proxmox"
  template_name  = "ubuntu-24.04-cloudinit"
  cpu_cores      = 2
  memory_mb      = 4096
  disk_size      = "20G"
  ssh_public_key = file("~/.ssh/id_rsa.pub")
}


# ==========================================================
# Docker-enabled Ubuntu VM
# ==========================================================
module "my_vm_docker" {
  source         = "./modules/proxmox-vm-docker"
  hostname       = "docker-vm01"
  node           = "proxmox"
  template_name  = "ubuntu-24.04-cloudinit"
  cpu_cores      = 2
  memory_mb      = 4096
  disk_size      = "20G"
  ssh_public_key = file("~/.ssh/id_rsa.pub")
}
