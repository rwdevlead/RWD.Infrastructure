terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
  }
}

resource "proxmox_virtual_environment_file" "ha_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = var.node_name

  source_file {
    # Expects an already-decompressed .img file (unzipped from .img.xz)
    path = "${path.module}/files/haos_ova-16.3.img"
  }

  # Ignore local file metadata drift after the HAOS image has been imported into the VM disk
  lifecycle {
    ignore_changes = [
      source_file,
    ]
  }
}

resource "proxmox_virtual_environment_vm" "home_assistant" {
  name        = var.vm_name
  description = var.vm_description
  node_name   = var.node_name
  vm_id       = var.vm_id

  bios    = var.vm_bios
  machine = var.vm_machine

  agent {
    enabled = true
  }

  # HAOS requires virtio-scsi-single for stable disk detection
  scsi_hardware = "virtio-scsi-single"

  # Primary disk interface must precede net0 so HAOS boots from disk instead of PXE
  boot_order = [var.disk_interface, "net0"]

  cpu {
    cores = var.vm_cores
    type  = "host"
  }

  memory {
    dedicated = var.vm_memory
  }

  network_device {
    bridge = var.network_bridge
  }

  efi_disk {
    datastore_id = var.efi_storage_id
    type         = "4m"
  }

  disk {
    datastore_id = var.disk_storage_id
    file_id      = proxmox_virtual_environment_file.ha_image.id
    interface    = var.disk_interface
    size         = var.disk_size
    ssd          = true
    discard      = "on"
  }

  operating_system {
    type = var.vm_os
  }

  on_boot = var.vm_on_boot

  tags = var.tags

  # Ignore post-import disk attribute differences managed internally by Proxmox/HAOS
  lifecycle {
    ignore_changes = [
      disk,
    ]
  }
}
