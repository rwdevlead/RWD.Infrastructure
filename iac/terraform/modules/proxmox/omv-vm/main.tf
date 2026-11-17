terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
  }
}

resource "proxmox_virtual_environment_vm" "omv" {
  name        = var.vm_name
  description = var.vm_description
  node_name   = var.proxmox_node_name
  vm_id       = var.vm_id
  on_boot     = var.vm_on_boot

  agent {
    # Requires qemu-guest-agent inside the OMV guest so Proxmox can report IP addresses
    enabled = true
  }

  scsi_hardware = "virtio-scsi-pci"
  machine       = var.vm_machine
  bios          = var.vm_bios

  vga {
    type   = "virtio"
    memory = 128
  }

  cpu {
    cores = var.vm_cores
    type  = "host"
  }

  memory {
    dedicated = var.vm_memory_max
    floating  = var.vm_memory_min
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  # Attached as ide2 for initial ISO installation; callers pass "none" afterward
  cdrom {
    file_id   = var.iso_file_id
    interface = "ide2"
  }

  initialization {
    datastore_id = var.boot_datastore
    # Use sata0 to avoid colliding with the ide2 CD-ROM device
    interface = "sata0"
  }

  # Boot installer ISO before OS disk on initial provisioning
  boot_order = ["ide2", "scsi0"]

  disk {
    datastore_id = var.boot_datastore
    interface    = var.disk_interface
    size         = var.disk_size
    file_format  = "raw"
    ssd          = true
    discard      = "on"
    serial       = "BOOTDISK001"
  }

  efi_disk {
    datastore_id = var.boot_datastore
    file_format  = "raw"
    type         = "4m"
  }

  operating_system {
    type = "l26"
  }

  tags = var.tags
}

# Attach raw /dev/disk/by-id passthrough via qm CLI because the Proxmox API token lacks host-device passthrough permissions
resource "null_resource" "assign_passthrough_disk" {
  triggers = {
    vm_id = proxmox_virtual_environment_vm.omv.id
    disk  = var.data_disk_id
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 10",
      "qm set ${var.vm_id} -scsi1 /dev/disk/by-id/${var.data_disk_id},serial=1,backup=0"
    ]

    connection {
      type        = "ssh"
      user        = "root"
      host        = var.proxmox_node_ip
      private_key = var.ssh_private_key_content
      # Disable SSH agent forwarding so connection uses only the explicit private key
      agent   = false
      timeout = "1m"
    }
  }

  # Ensure the VM exists in Proxmox before running qm set over SSH
  depends_on = [proxmox_virtual_environment_vm.omv]
}
