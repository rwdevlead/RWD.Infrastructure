terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      # version = "0.89.1" # version = ">=0.66"
    }
  }
}

resource "proxmox_virtual_environment_vm" "truenas_scale" {
  name        = var.vm_name
  description = "TrueNAS SCALE - Managed by Terraform"
  node_name   = var.proxmox_node
  vm_id       = var.vm_id

  machine = "q35"
  bios    = "ovmf"

  vga {
    # virtio is the modern standard for Linux VMs
    type = "virtio"
    # 128MB is plenty for a text/web-based OS installer 
    memory = 128
  }

  cpu {
    cores = var.cpu_cores
    type  = "host"
  }

  memory {
    dedicated = var.memory_mb
    floating  = var.memory_mb # Disable ballooning for ZFS
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  # OS Boot Drive (Virtual Disk)
  disk {
    datastore_id = var.boot_datastore
    interface    = "scsi0"
    size         = 32
    file_format  = "raw"
    ssd          = true
    discard      = "on"
  }

  cdrom {
    file_id   = var.iso_file_id
    interface = "ide2"
  }

  efi_disk {
    datastore_id = var.boot_datastore
    file_format  = "raw"
    type         = "4m"
  }

  operating_system {
    type = "l26"
  }

  # Required for the TrueNAS install console
  #   serial_device {}

  tags = var.tags
}

# This handles the disk passthrough that the API blocked
resource "null_resource" "assign_passthrough_disk" {
  triggers = {
    vm_id = proxmox_virtual_environment_vm.truenas_scale.id
    disk  = var.data_disk_id
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 10",
      "qm set ${var.vm_id} -scsi1 /dev/disk/by-id/${var.data_disk_id}"
    ]

    connection {
      type = "ssh"
      user = "root"
      host = "192.168.50.11"
      # Match the key from your provider block
      private_key = file("~/.ssh/id_ed25519")
      agent       = false # Keeps it clean
      timeout     = "1m"
    }
  }

  depends_on = [proxmox_virtual_environment_vm.truenas_scale]
}
