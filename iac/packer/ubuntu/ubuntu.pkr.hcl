
locals {
  # VM Hardware specifications
  cores           = 2
  memory          = 8192 # memory in MB → 8 GB
  scsi_controller = "virtio-scsi-pci"
  disk = {
    disk_size         = "20G"
    format            = "raw"
    storage_pool      = "local-lvm"
    storage_pool_type = "lvm"
    type              = "scsi"
  }
  network = {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = "false"
  }

}

# ==========================================================
# Packer Required Plugins
# ==========================================================
packer {
  required_plugins {
    name = {
      version = "1.1.3"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

# ==========================================================
# Proxmox Source Template (Ubuntu Base)
# ==========================================================
source "proxmox-iso" "ubuntu" {

  # -------------------------------
  # Proxmox Connection Settings
  # -------------------------------
  # Proxmox connection settings from variables
  proxmox_url = var.proxmox_url
  username    = var.username
  token       = var.token

  # Destination template settings
  node          = var.node
  vm_id         = var.vm_id
  template_name = var.template_name

  # -------------------------------
  # VM OS / Hardware Settings
  # -------------------------------
  cores           = local.cores
  memory          = local.memory
  scsi_controller = local.scsi_controller

  # -------------------------------
  # Disk Configuration
  # -------------------------------
  disks {
    disk_size    = local.disk.disk_size
    format       = local.disk.format
    storage_pool = local.disk.storage_pool
    # storage_pool_type = local.disk.storage_pool_type
    type = local.disk.type
  }


  # -------------------------------
  # Network Configuration
  # -------------------------------
  network_adapters {
    model    = local.network.model
    bridge   = local.network.bridge
    firewall = local.network.firewall
  }

  qemu_agent = true

  # SSH connection settings for provisioning
  # Uses password auth during build; provisioners inject SSH key afterward
  ssh_username = "root"
  ssh_password = "ubuntu"
  ssh_private_key_file = ""

  ssh_timeout            = "30m"
  ssh_wait_timeout       = "25m"
  ssh_port               = 22
  ssh_handshake_attempts = 200

  # Ubuntu Live Server ISO (proxmox-iso builder requires ISO file)
  iso_file         = var.iso_file
  unmount_iso      = true
  iso_storage_pool = "iso-images"

  # Cloud-init datasource configuration
  # HTTP server serves user-data and meta-data files for autoinstall
  http_directory = "http"

  boot_wait         = "20s"
  boot_key_interval = "120ms"

  # Boot kernel parameters:
  # - autoinstall: enables unattended Ubuntu Server installation
  # - ds=nocloud-net;s=http://IP:PORT/: cloud-init datasource over HTTP
  # - console=ttyS0,115200n8: serial console output (for debugging)
  # - systemd.log_level=debug: verbose system logging
  boot_command = [
    "<esc><wait>",
    "c<wait>",
    "linux /casper/vmlinuz root=/casper/filesystem.squashfs ro autoinstall 'ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/' console=ttyS0,115200n8 systemd.log_level=debug <enter>",
    "initrd /casper/initrd <enter>",
    "boot <enter>"
  ]


}


# ==========================================================
# Build Section
# ==========================================================
build {
  name    = "ubuntu-template"
  sources = ["source.proxmox-iso.ubuntu"]

  # Wait for system boot and services to stabilize
  provisioner "shell" {
    inline = [
      "echo 'System booted, waiting for services to start...'",
      "sleep 10",
      "echo 'System ready for provisioning!'"
    ]
  }

  # Inject SSH public key for key-based authentication
  # (root password is disabled in favor of key auth for security)
  provisioner "shell" {
    inline = [
      "mkdir -p /root/.ssh",
      "chmod 700 /root/.ssh",
      "echo '${var.ssh_pub_key}' >> /root/.ssh/authorized_keys",
      "chmod 600 /root/.ssh/authorized_keys",
      "echo 'SSH key added to root user'"
    ]
  }

  # Clean up cloud-init state to prevent re-provisioning on clone/boot
  # Truncate machine-id so each cloned VM gets a new unique ID
  provisioner "shell" {
    inline = [
      "echo 'Cleaning up cloud-init and preparing template...'",
      "sudo truncate -s 0 /etc/machine-id",
      "sudo cloud-init clean --logs --seed",
      "sudo sync"
    ]
  }

}