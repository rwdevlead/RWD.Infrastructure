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
source "proxmox-iso" "ubuntu" {

  # -------------------------------
  # Proxmox Connection Settings
  # -------------------------------
  proxmox_url  = "https://proxmox.example.local:8006/api2/json"
  username     = "root@pam!rwd-iac"
  token        = "ff2fcab2-fad4-448b-811d-56bf3b5b609f"
  ssh_username = "root"
  # token_secret = var.proxmox_token_secret

  # -------------------------------
  # Destination
  # -------------------------------
  node          = "proxmox"
  vm_id         = 9000
  template_name = "ubuntu-24.04-template"

  # -------------------------------
  # VM OS / Hardware Settings
  # -------------------------------
  cores              = 2
  memory             = 8192 # memory in MB → 8 GB
  scsi_controller    = "virtio-scsi-pci"
  # bootdisk           = "scsi0"

  # -------------------------------
  # Disk Configuration
  # -------------------------------
  disks {
    disk_size    = "20G"
    format       = "qcow2"
    storage_pool = "local-lvm"
    # storage_pool_type = "lvm"
    type = "virtio"
  }

  # -------------------------------
  # Network Configuration
  # -------------------------------
  network_adapters {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = "false"
  }

  qemu_agent = true

  # -------------------------------
  # VM OS / Installation Settings
  # -------------------------------
  # iso_file         = var.iso_file
  # iso_storage_pool = "local"

  boot_iso {
    type     = "scsi"
    iso_file = "local:iso/ubuntu-22.04.5-live-server-amd64.iso"
    unmount  = true
    #iso_checksum = "sha512:33c08e56c83d13007e4a5511b9bf2c4926c4aa12fd5dd56d493c0653aecbab380988c5bf1671dbaea75c582827797d98c4a611f7fb2b131fbde2c677d5258ec9"
  }

  # -------------------------------
  # Autoinstall / Unattended Settings
  # -------------------------------
  # cloud_init              = true
  # cloud_init_storage_pool = "local-lvm"

  # PACKER Autoinstall Settings
  http_directory = "http"

  boot_wait = "5s"
  boot_command = [
    "<enter><wait>",
    "/install/vmlinuz auto ",
    "ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ",
    "initrd=/install/initrd.gz ",
    "console-setup/ask_detect=false ",
    "<enter>"
  ]


}

# ==========================================================
# Build Section
# ==========================================================
build {
  name    = "ubuntu-template"
  sources = ["source.proxmox-iso.ubuntu"]

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