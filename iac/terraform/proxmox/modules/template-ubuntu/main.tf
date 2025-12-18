
terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      # version = "0.89.1" # version = ">=0.66"
    }
    null = {
      source = "hashicorp/null"
      # version = "~> 3.0"
    }
  }
}

resource "proxmox_virtual_environment_vm" "template" {

  node_name = var.node_name

  name  = var.vm_name
  vm_id = var.vm_id

  template = false
  started  = false

  machine     = var.vm_machine
  bios        = var.vm_bios
  description = "Managed by Terraform"

  scsi_hardware = "virtio-scsi-pci"

  operating_system {
    type = var.vm_os
  }

  cpu {
    type  = "host"
    cores = var.vm_cores
  }

  memory {
    dedicated = var.vm_memory
  }

  agent {
    enabled = true
  }

  efi_disk {
    datastore_id = var.efi_storage_id
    type         = "4m"
  }

  disk {
    datastore_id = var.disk_storage_id
    file_id      = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
    interface    = var.disk_interface
    iothread     = true
    discard      = "on"
    size         = var.disk_size
  }


  initialization {
    # The user account configuration (conflicts with user_data_file_id per the provider
    # user_account {
    #   keys     = [var.ssh_public_key_content]
    #   username = "ka8kgj"
    #   password = "password123"
    # }
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
    user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_config.id
  }

  network_device {
    bridge = var.network_bridge
  }

  # onboot = false
  tags = ["template"]


}

resource "proxmox_virtual_environment_file" "user_data_cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.node_name

  # Use source_raw instead of source_file or content
  source_raw {
    data = templatefile("${path.module}/cloudinit.yaml", {
      hostname       = var.vm_name
      ssh_public_key = var.ssh_public_key_content
    })

    file_name = "cloud-config-${var.vm_name}.yaml"
  }
}

resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  content_type = "iso"
  datastore_id = var.iso_target
  node_name    = var.node_name
  url          = var.iso_url
  # checksum           = var.iso_checksum
  # checksum_algorithm = var.iso_checksum_algorithm
  # overwrite          = false
}




# resource "proxmox_virtual_environment_file" "user_data_cloud_config" {
#   content_type = "snippets"
#   datastore_id = "local"
#   node_name    = var.node_name
#   source_file {
#     path = "${path.module}/cloudinit.yaml"
#   }
# }

