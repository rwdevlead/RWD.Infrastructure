terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
  }
}

resource "proxmox_virtual_environment_vm" "template" {
  node_name = var.node_name
  name      = var.vm_name
  vm_id     = var.vm_id

  template = var.template_mode
  started  = var.vm_startup

  machine     = var.vm_machine
  bios        = var.vm_bios
  description = "Ubuntu Template - Managed by Terraform"

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
    datastore_id = var.disk_storage_id

    # Omit user_account because bpg/proxmox rejects it alongside user_data_file_id; cloudinit.yaml configures user/SSH
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

  tags = ["template", "terraform"]

  # Ignore post-seal state transitions after cleanup_vm.sh and convert_to_template.sh convert the VM to a template
  lifecycle {
    ignore_changes = [
      template,
      started,
      initialization,
      network_device,
    ]
  }
}

resource "proxmox_virtual_environment_file" "user_data_cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.node_name

  # Use source_raw so rendered templatefile() content uploads directly without a separate staging file
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
}
