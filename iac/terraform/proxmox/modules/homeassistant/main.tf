terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      # version = "0.89.1" # version = ">=0.66"
    }
  }
}

resource "proxmox_virtual_environment_storage_file" "haos" {
  node         = var.node
  datastore_id = var.storage
  download_url = var.qcow2_url
  file_name    = "${var.name}.qcow2"
}

resource "proxmox_virtual_environment_vm" "ha" {
  vm_id = var.vm_id
  name  = var.name
  node  = var.node

  disk {
    datastore_id = var.storage
    file_id      = proxmox_virtual_environment_storage_file.haos.id
  }

  operating_system {
    type = "l26"
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 4096
  }

  network_device {}
}
