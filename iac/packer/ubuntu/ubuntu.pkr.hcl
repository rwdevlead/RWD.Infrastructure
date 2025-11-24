
locals {
  # ice_cream_flavor = "${var.flavor}-ice-cream"
  cores           = 2
  memory          = 8192 # memory in MB → 8 GB
  scsi_controller = "virtio-scsi-pci"
  qemu_agent      = false
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
  proxmox_url = var.proxmox_url
  username    = var.username
  token       = var.token



  # ADD THIS LINE ONLY IN LOCAL USE
  # insecure = true

  # -------------------------------
  # Destination
  # -------------------------------
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

  qemu_agent = local.qemu_agent

  # ssh_username = var.ssh_username
  # # Set a generous SSH timeout to allow for full OS install and boot
  # ssh_timeout = "15m"
  # # Set the interval for retry attempts 
  # ssh_wait_timeout = "10m" # Crucial: Allow 10 minutes for the VM to reboot and SSH to start


  ssh_username = "root"
  # The plaintext password for the hash you provided (Password: "ubuntu")
  ssh_password = "ubuntu"

  # 💥 CRITICAL: Empty the private key path to force Packer to use the password
  ssh_private_key_file = ""

  ssh_timeout      = "15m"
  ssh_wait_timeout = "10m"
  ssh_port         = 22

  # -------------------------------
  # VM OS / Installation Settings v1.1.3
  # -------------------------------
  iso_file         = var.iso_file
  unmount_iso      = true
  iso_storage_pool = "iso-images"


  # -------------------------------
  # VM OS / Installation Settings v1.2.3
  # -------------------------------
  # boot_iso {
  #   type     = "ide"
  #   iso_file = var.iso_file
  #   unmount  = true
  #   #iso_checksum = "sha512:33c08e56c83d13007e4a5511b9bf2c4926c4aa12fd5dd56d493c0653aecbab380988c5bf1671dbaea75c582827797d98c4a611f7fb2b131fbde2c677d5258ec9"
  # }

  # -------------------------------
  # Autoinstall / Unattended Settings
  # -------------------------------
  # cloud_init              = true
  # cloud_init_storage_pool = "local-lvm"

  # PACKER Autoinstall Settings
  http_directory = "http"

  boot_wait         = "20s"
  boot_key_interval = "120ms"

  # boot_command = [
  #   "<esc><wait>",
  #   "c<wait>",

  #   # Use the correct paths and command line parameters
  #   "linux /casper/vmlinuz autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ci-cfgname=autoinstall ---<enter>",
  #   "initrd /casper/initrd<enter>",
  #   "boot<enter>"
  # ]

  # boot_command = [
  #   "<esc><wait>",
  #   "c<wait>",
  #   # This command includes the 'break=top' parameter to force a pause/shell.
  #   "linux /casper/vmlinuz console=ttyS0 autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ break=top ---<enter>",
  #   "initrd /casper/initrd<enter>",
  #   "boot<enter>"
  # ]

  # ➡️ Use this in your source block
  boot_command = [
    "<esc><wait>",
    "c<wait>",
    # Hardcode the MacBook's IP (192.168.50.165) for the HTTP server location
    "linux /casper/vmlinuz autoinstall ds=nocloud-net\\;s=http://192.168.50.165:{{ .HTTPPort }}/ ---<enter>",
    "initrd /casper/initrd<enter>",
    "boot<enter>"
  ]


}


# ==========================================================
# Build Section
# ==========================================================
build {
  name    = "ubuntu-template"
  sources = ["source.proxmox-iso.ubuntu"]

  provisioner "file" {
    source      = "http/autoinstall.yaml" // Adjust path if file is elsewhere
    destination = "http/autoinstall.yaml"
  }

  # Wait for cloud-init to finish initialization
  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      "sudo truncate -s 0 /etc/machine-id",
      "sudo cloud-init clean",
      "sudo sync"
    ]
  }


  # ----------------------------------------------------------
  # Install Proxmox cloud-init config
  # ----------------------------------------------------------
  provisioner "file" {
    source      = "files/99-pve.cfg"
    destination = "/tmp/99-pve.cfg"
  }

  provisioner "shell" {
    inline = [
      "sudo mv /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg",
      "sudo chown root:root /etc/cloud/cloud.cfg.d/99-pve.cfg",
      "sudo chmod 644 /etc/cloud/cloud.cfg.d/99-pve.cfg"
    ]
  }

}