


resource "proxmox_vm_qemu" "vm" {
  name        = var.vm_name
  target_node = var.node_name
  clone       = var.clone_template
  full_clone  = true
  cores       = var.cpu_cores
  memory      = var.memory_mb

  # Optional explicit ID
  dynamic "vmid" {
    for_each = var.vm_id != null ? [var.vm_id] : []
    content {
      vmid = vmid.value
    }
  }

  disk {
    size    = "${var.disk_size_gb}G"
    type    = "scsi"
    storage = var.storage_pool
  }

  network {
    model  = "virtio"
    bridge = var.network_bridge
  }

  # Cloud-init
  ipconfig0 = var.ip_address != "" ? "ip=${var.ip_address},gw=${var.gateway}" : "ip=dhcp"
  sshkeys   = var.ssh_public_key

  os_type = "cloud-init"
  agent   = 1

  lifecycle {
    ignore_changes = [
      network, # prevent unnecessary changes due to MAC/IP updates
    ]
  }
}
