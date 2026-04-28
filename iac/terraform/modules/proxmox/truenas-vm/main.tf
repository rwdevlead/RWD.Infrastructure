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
  description = var.vm_description
  node_name   = var.proxmox_node_name
  vm_id       = var.vm_id

  scsi_hardware = "virtio-scsi-pci"
  machine       = var.vm_machine
  bios          = var.vm_bios

  # virtio is the modern standard for Linux VMs
  # 128MB is plenty big
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

  # 1. The Installer (Keep this for the first run)
  cdrom {
    file_id   = var.iso_file_id
    interface = "ide2"
  }

  # 2. The Cloud-Init "Static IP" Drive
  initialization {
    datastore_id = var.boot_datastore
    interface    = "sata0" # Using SATA prevents the IDE conflict
  }

  # 3. Define the Boot Order clearly
  # During install: [cdrom, scsi0] | After install: [scsi0]
  boot_order = ["ide2", "scsi0"]

  # OS Boot Drive (Virtual Disk)
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
      # Using the explicit variable for the ID often prevents string/int type mismatches
      "qm set ${var.vm_id} -scsi1 /dev/disk/by-id/${var.data_disk_id},serial=1,backup=0"
    ]

    connection {
      type = "ssh"
      user = "root"
      host = var.proxmox_node_ip
      # Match the key from your provider block
      private_key = var.ssh_private_key_content #file("~/.ssh/id_ed25519")
      agent       = false                       # Keeps it clean
      timeout     = "1m"
    }
  }

  depends_on = [proxmox_virtual_environment_vm.truenas_scale]
}
