
locals {
  # VM Hardware specifications
  cores           = 2
  memory          = 8192 # memory in MB → 8 GB
  scsi_controller = "virtio-scsi-pci"
  disk = {
    disk_size    = "32G"
    format       = "raw"
    storage_pool = "local-lvm"
    type         = "scsi"
  }
  network = {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = false
  }

  buildtime = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())

}

# ==========================================================
# Packer Required Plugins
# ==========================================================
packer {
  required_plugins {
    name = {
      version = "1.2.3"
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
  proxmox_url              = var.proxmox_url
  username                 = var.username
  token                    = var.token
  insecure_skip_tls_verify = true

  # -------------------------------
  # Destination template settings
  # -------------------------------
  node                 = var.node
  vm_id                = var.vm_id
  template_name        = var.template_name
  template_description = "Ubuntu 24.04 Server Template, built with Packer on ${local.buildtime}"

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
    type         = local.disk.type
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


  # -------------------------------
  # Cloud-Init Drive Configuration 
  # ------------------------------- 
  cloud_init              = false
  cloud_init_storage_pool = local.disk.storage_pool # Use your LVM pool for consistency
  cloud_init_disk_type    = "scsi"                  # Standard attachment type (only v1.2.3)

  # -------------------------------
  # Communicator Settings
  # -------------------------------
  ssh_username     = "ubuntu"
  ssh_password     = "ubuntu"
  ssh_timeout      = "30m"
  ssh_wait_timeout = "20m"
  # ssh_port               = 22
  # ssh_handshake_attempts = 200

  boot_iso {
    iso_file = var.iso_file
    # iso_url          = var.iso_url
    iso_checksum     = var.iso_checksum
    iso_storage_pool = "iso-images"
    unmount          = true
  }

  # Cloud-init datasource configuration
  # HTTP server serves user-data and meta-data files for autoinstall
  http_directory = "http"

  # Explicitly set boot order to prefer scsi0 (installed disk) over ide devices
  boot = "c"

  # boot_disk_storage = "local-lvm:20,format=qcow2,scsi0"
  boot_wait         = "20s"
  boot_key_interval = "120ms"
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

  # Provisioning the VM Template
  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      "sudo systemctl enable qemu-guest-agent",
      "sudo systemctl start qemu-guest-agent",
      "sudo cloud-init clean",
      "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
      "sudo rm -f /etc/netplan/00-installer-config.yaml",
      "echo 'Ubuntu 24.04 Template by Packer - Creation Date: $(date)' | sudo tee /etc/issue"
    ]
  }

  # Added provisioner to forcibly eject ISO and prepare for reboot
  provisioner "shell" {
    inline = [
      "echo 'Completed installation. Preparing for template conversion...'",
      "echo 'Ejecting CD-ROM devices...'",
      "sudo eject /dev/sr0 || true",
      "sudo eject /dev/sr1 || true",
      "echo 'Removing CD-ROM entries from fstab if present...'",
      "sudo sed -i '/cdrom/d' /etc/fstab",
      "sudo sync",
      "echo 'Setting disk as boot device...'",
      "sudo sed -i 's/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=1/' /etc/default/grub",
      "sudo update-grub",
      "echo 'Clearing cloud-init status to ensure fresh start on first boot...'",
      "sudo cloud-init clean --logs",
      "echo 'Installation and cleanup completed successfully!'"
    ]
    expect_disconnect = true
  }


}

