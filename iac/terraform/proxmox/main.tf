locals {
  # Common repository features
  host_info = {
    name    = "proxmox"
    gateway = "192.168.50.1"
    storage = {
      boot_disk    = ""
      storage_pool = "lvm"
    }
    has_projects = false
    auto_init    = true
  }

  iso_templates = {
    ubuntu = "ubuntu-22.04-cloudinit"
  }

  # Managed by information
  managed_by = "Managed by Terraform"
}

module "ubuntu_vm" {
  source = "./modules/proxmox-vm"

  proxmox_endpoint     = "https://proxmox.local:8006/api2/json"
  proxmox_token_id     = "terraform@pve!mytoken"
  proxmox_token_secret = "supersecret"
  node_name            = local.host_info.name
  vm_name              = "ubuntu-docker"
  clone_template       = local.iso_templates.ubuntu
  storage_pool         = "local-lvm"
  ip_address           = "192.168.50.15/24"
  gateway              = local.host_info.gateway
  ssh_public_key       = file("~/.ssh/id_rsa.pub")
}
