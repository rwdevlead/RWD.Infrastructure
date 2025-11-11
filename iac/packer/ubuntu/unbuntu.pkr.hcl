# ==========================================================
# Packer Required Plugins
# ==========================================================
packer {
  required_plugins {
    name = {
      version = "~> 1"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

# ==========================================================
# Proxmox Source Template (Ubuntu Base)
# ==========================================================
source "proxmox" "ubuntu" {

  # -------------------------------
  # Proxmox Connection Settings
  # -------------------------------
  proxmox_url      = var.proxmox_url
  username         = var.proxmox_user
  token_id         = var.proxmox_token_id
  token_secret     = var.proxmox_token_secret

  # -------------------------------
  # VM General Settings
  # -------------------------------
  node             = "proxmox"
  vm_id            = var.vm_id
  template_name    = var.template_name

  # -------------------------------
  # VM OS / Installation Settings
  # -------------------------------
  iso_file         = var.iso_file
  iso_storage_pool = "local"

  cores            = 2
  memory           = 2048
  scsi_controller  = "virtio-scsi-pci"
  bootdisk         = "scsi0"

  # -------------------------------
  # Autoinstall / Unattended Settings
  # -------------------------------
  boot_command = [
    "<enter><wait>",
    "/install/vmlinuz auto ",
    "ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ",
    "initrd=/install/initrd.gz ",
    "console-setup/ask_detect=false ",
    "<enter>"
  ]

  cloud_init                  = true
  cloud_init_user_data_file   = "iac/packer/ubuntu-server-focal/cloud-init/user-data"
  cloud_init_storage_pool     = "local-lvm"
  unmount_iso                 = true
  os_type                     = "cloud-init"

  qemu_agent = true

  # -------------------------------
  # Disk Configuration
  # -------------------------------
  disks {
    disk_size         = "20G"
    format            = "qcow2"
    storage_pool      = "local-lvm"
    storage_pool_type = "lvm"
    type              = "virtio"
  }

  # -------------------------------
  # Network Configuration
  # -------------------------------
  network_adapters {
    model   = "virtio"
    bridge  = "vmbr0"
    firewall = "false"
  }
}

# ==========================================================
# Build Section
# ==========================================================
build {
  name    = "ubuntu-template"
  sources = ["source.proxmox.ubuntu"]

  # -------------------------------
  # Provisioners
  # -------------------------------
  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get -y upgrade"
    ]
  }
}