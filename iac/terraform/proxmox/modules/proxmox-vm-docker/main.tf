terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc06"
    }
  }
}

resource "proxmox_vm_qemu" "vm" {
  name        = var.hostname
  target_node = var.node
  clone       = var.template_name
  full_clone  = true
  vmid        = var.vmid

  cpu {
    cores = var.cpu_cores
  }

  memory = var.memory_mb

  disk {
    slot    = "scsi0"
    size    = var.disk_size
    type    = "disk"
    storage = "local-lvm"
  }

  network {
    id     = 0
    model  = "virtio"
    bridge = var.bridge
  }

  # Cloud-init
  ciuser    = "root"
  sshkeys   = var.ssh_public_key
  ipconfig0 = "ip=${var.ip_address}/${var.netmask},gw=${var.gateway}"
  cicustom  = "user=cloudinit.yaml.tpl"

  # Enable template rendering
  # template = true   # only needed if creating a template; leave false for deployment

}
