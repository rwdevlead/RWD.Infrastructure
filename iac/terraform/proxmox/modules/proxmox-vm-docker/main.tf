terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc06"
    }
  }
}

resource "proxmox_vm_qemu" "vm" {
  name          = var.hostname
  target_node   = var.node
  clone         = var.template_name
  full_clone    = true
  vmid          = var.vmid
  agent         = 1
  agent_timeout = 800

  cpu {
    cores = var.cpu_cores
  }

  # os              = local.os
  # machine         = local.machine
  # bios            = local.bios
  # see notes

  memory = var.memory_mb

  disk {
    slot    = "scsi0"
    size    = var.disk_size
    type    = "disk"
    storage = "local-lvm"
  }

  network {
    id     = 0
    model  = "virtio"
    bridge = var.bridge
  }

  # Cloud-init
  # ciuser    = "root"
  # sshkeys   = var.ssh_public_key
  # ipconfig0 = "ip=${var.ip_address}/${var.netmask},gw=${var.gateway}"
  # cicustom = "user=cloudinit.yaml.tpl"
  # cicustom = "user=${local_file.cloud_init_user_data.filename}"
  # cicustom = "user=local-lvm:${local_file.cloud_init_user_data.filename}"
  # cicustom = "user=local:snippets/${var.hostname}-user-data.yaml"
  # cicustom = "user=iso-images:snippets/${var.hostname}-user-data.yaml"

  # Ensure the VM waits for the file to be created
  # depends_on = [
  #   local_file.cloud_init_user_data
  # ]

}


# resource "local_file" "cloud_init_user_data" {
#   # This file will be created in your current Terraform directory
#   filename = "${path.module}/user_data_rendered.yaml"

#   # Render the template and inject variables
#   content = templatefile("${path.module}/cloudinit.yaml.tpl", {
#     hostname       = var.hostname,
#     ssh_public_key = var.ssh_public_key,
#     ip_address     = var.ip_address,
#     netmask        = var.netmask,
#     gateway        = var.gateway
#   })
# }

# resource "local_file" "cloud_init_user_data" {
#   filename = "/mnt/pve/iso-images/snippets/${var.hostname}-user-data.yaml"

#   content = templatefile("${path.module}/cloudinit.yaml.tpl", {
#     hostname       = var.hostname
#     ssh_public_key = var.ssh_public_key
#     ip_address     = var.ip_address
#     netmask        = var.netmask
#     gateway        = var.gateway
#   })
# }



# resource "proxmox_file" "cloud_init" {
#   source = templatefile("${path.module}/cloudinit.yaml.tpl", {
#     hostname       = var.hostname,
#     ssh_public_key = var.ssh_public_key,
#     ip_address     = var.ip_address,
#     netmask        = var.netmask,
#     gateway        = var.gateway
#   })
#   destination = "/var/lib/vz/snippets/${var.hostname}-user-data.yaml"
# }
