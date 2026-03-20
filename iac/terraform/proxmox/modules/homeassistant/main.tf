terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      # version = "0.89.1" # version = ">=0.66"
    }
  }
}


# resource "proxmox_virtual_environment_download_file" "ha_image" {
#   content_type = "iso"
#   datastore_id = "local"
#   node_name    = var.node_name
#   url          = var.qcow2_url

#   # This is the magic line for .xz files
#   decompression_algorithm = "xz"

#   # Ensure the destination filename ends in .img or .qcow2 
#   # so Proxmox recognizes it as a disk image after decompression
#   file_name = var.qcow2_filename
# }

resource "proxmox_virtual_environment_file" "ha_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = var.node_name

  source_file {
    # Ensure you have unzipped the .xz file to this path
    path = "${path.module}/files/haos_ova-16.3.img"
  }
}

resource "proxmox_virtual_environment_vm" "home_assistant" {
  name        = var.vm_name
  description = var.vm_description
  node_name   = var.node_name
  vm_id       = var.vm_id

  # Home Assistant OS requires UEFI
  bios    = var.vm_bios
  machine = var.vm_machine

  agent {
    enabled = true
  }

  # HAOS is very picky about the SCSI controller type. 
  # 'virtio-scsi-single' is the most stable for HAOS.
  scsi_hardware = "virtio-scsi-single"

  # THIS IS THE CRITICAL ADDITION:
  # 'scsi0' (or whatever var.disk_interface is) must be first.
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

  # EFI Disk (Required for UEFI boot)
  efi_disk {
    datastore_id = var.efi_storage_id
    type         = "4m"
  }

  # The Main Disk imported from the image
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

  # Ensure the VM starts on boot
  on_boot = true

  tags = var.tags

}

