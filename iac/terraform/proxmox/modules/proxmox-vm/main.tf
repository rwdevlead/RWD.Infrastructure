terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc06"
    }
  }
}

resource "proxmox_vm_qemu" "vm" {

  depends_on = [null_resource.upload_cloudinit]

  name        = var.hostname
  target_node = var.node
  clone       = var.template_name
  full_clone  = true
  vmid        = var.vmid

  # cores  = var.cpu_cores
  memory = var.memory_max_mb
  # memory  = var.memory_max_mb
  # balloon = var.memory_min_mb

  cpu {
    cores = var.cpu_cores
  }

  # vm_state   = "running"

  # Network config via cloud-init
  ciuser    = "ka8kgj"
  sshkeys   = var.ssh_public_key
  ipconfig0 = "ip=${var.ip_address}/${var.netmask},gw=${var.gateway}"

  # ONLY include if using a snippet file
  # cicustom = "user=snippets/cloudinit.yaml"
  cicustom = "/var/lib/vz/snippets/${var.hostname}-cloudinit.yaml"

  # # Cloud-init
  # ciuser    = "ka8kgj"
  # sshkeys   = var.ssh_public_key
  # ipconfig0 = "ip=${var.ip_address}/${var.netmask},gw=${var.gateway}"
  # cicustom  = "user=local:snippets/cloudinit.yaml"

  # Always needed
  agent = 1

  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
  }

  # network {
  #   id     = 0
  #   model  = "virtio"
  #   bridge = var.bridge
  # }




  # SCSI settings for modern Ubuntu/DEB-based cloud templates
  scsihw   = "virtio-scsi-pci"
  boot     = "order=scsi0"
  bootdisk = "scsi0"
  disk {
    slot     = "scsi0"
    size     = var.disk_size
    type     = "disk"
    storage  = "local-lvm"
    iothread = true
  }

  # boot    = "cdn"
  # qemu_os = var.vm_os
  # machine = var.vm_machine
  # bios    = var.vm_bios


  # disk {
  #   slot    = "scsi0"
  #   size    = var.disk_size
  #   type    = "disk"
  #   storage = "local-lvm"
  # }






}

# # create cloud init file
locals {
  cloudinit_yaml = file("${path.module}/cloudinit.yaml")
}

resource "null_resource" "upload_cloudinit" {
  triggers = {
    cloudinit = local.cloudinit_yaml
  }

  provisioner "file" {
    content     = local.cloudinit_yaml
    destination = "/var/lib/vz/snippets/${var.hostname}-cloudinit.yaml"
  }

  connection {
    host     = "192.168.50.11"
    type     = "ssh"
    user     = "root"
    password = "I.h@t3.w33D$"
  }
}
