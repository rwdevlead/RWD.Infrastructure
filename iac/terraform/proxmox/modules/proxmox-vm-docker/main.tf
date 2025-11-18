resource "proxmox_vm_qemu" "vm" {
  name        = var.hostname
  target_node = var.node
  clone       = var.template_name
  full_clone  = true

  cores  = var.cpu_cores
  memory = var.memory_mb

  disk {
    size    = var.disk_size
    type    = "scsi"
    storage = "local-lvm"
  }

  network {
    model  = "virtio"
    bridge = var.bridge
  }

  # Cloud-init
  ciuser    = "ubuntu"
  sshkeys   = var.ssh_public_key
  ipconfig0 = "dhcp"
  cicustom  = "user=cloudinit.yaml.tpl"

  # Enable template rendering
  # template = true   # only needed if creating a template; leave false for deployment
}
