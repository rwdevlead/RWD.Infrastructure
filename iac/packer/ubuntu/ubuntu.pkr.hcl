
locals {
  # VM Hardware specifications
  cores           = 2
  memory          = 8192 # memory in MB → 8 GB
  scsi_controller = "virtio-scsi-pci"
  disk = {
    disk_size         = "24G"
    format            = "raw"
    storage_pool      = "local-lvm"
    storage_pool_type = "lvm"
    type              = "scsi"
  }
  network = {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = false
  }

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

  #qemu_agent = false # default is true

  # --- Cloud-Init Drive Configuration ---
  cloud_init = false
  # cloud_init_storage_pool = local.disk.storage_pool # Use your LVM pool for consistency
  # cloud_init_disk_type    = "scsi"                  # Standard attachment type (only v1.2.3)

  # SSH connection settings for provisioning
  # Uses password auth during build; provisioners inject SSH key afterward
  ssh_username = "ubuntu"
  ssh_password = "ubuntu"
  # ssh_private_key_file = ""

  ssh_timeout            = "30m"
  ssh_wait_timeout       = "25m"
  ssh_port               = 22
  ssh_handshake_attempts = 200

  # Ubuntu Live Server ISO (proxmox-iso builder requires ISO file)
  # iso_file         = var.iso_file
  # unmount_iso      = true
  # iso_storage_pool = "iso-images"

  boot_iso {
    iso_file = var.iso_file
    unmount  = true
  }

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

  # QGA Wait Provisioner (Crucial for Reliability) ---
  # provisioner "shell" {
  #   # Wait for the QEMU Guest Agent to become responsive
  #   inline = [
  #     "echo 'Waiting for QEMU Guest Agent to start...'",
  #     # Loop until the agent is accessible
  #     "until systemctl is-active qemu-guest-agent; do sleep 5; done",
  #     "echo 'QEMU Guest Agent is active.'"
  #   ]
  #   # Set a timeout in case the service never starts
  #   timeout = "5m" 
  # }

  # Wait for system boot and services to stabilize
  # provisioner "shell" {
  #   inline = [
  #     "echo 'Waiting for cloud-init and installer to finish...'",

  #     # 1. Wait for the final reboot to settle (needed after autoinstall)
  #     "sleep 30",

  #     # 2. Check for a file that is only present during the installation phase.
  #     #    If /var/lib/cloud/instance/boot-finished is present, it means cloud-init is done.
  #     "until [ -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for boot-finished file...'; sleep 5; done",

  #     # 3. Final, long sleep to ensure all services are up and the agent is started.
  #     "echo 'Cloud-init finished. Final 60-second wait for QGA and services.'",
  #     "sleep 60"
  #   ]
  #   # Increase the overall connection timeout if necessary
  #   timeout = "10m"
  # }

  # Inject SSH public key for key-based authentication
  # (root password is disabled in favor of key auth for security)
  # provisioner "shell" {
  #   inline = [
  #     "mkdir -p /root/.ssh",
  #     "chmod 700 /root/.ssh",
  #     "echo '${var.ssh_pub_key}' >> /root/.ssh/authorized_keys",
  #     "chmod 600 /root/.ssh/authorized_keys",
  #     "echo 'SSH key added to root user'"
  #   ]
  # }

  # ------------------------------------------------------------------
  # Provisioner: Enforce Static Netplan Precedence
  # ------------------------------------------------------------------
  # provisioner "shell" {
  #   inline = [
  #     "echo 'Writing Netplan configuration to disable DHCP...'",

  #     # CRITICAL: Write a Netplan file to explicitly disable DHCP
  #     # This prevents the VM from grabbing a DHCP lease when Terraform injects the static IP
  #     "sudo bash -c 'cat << EOF > /etc/netplan/99-static-netcfg.yaml",
  #     "network:",
  #     "  version: 2",
  #     "  renderer: networkd",
  #     "  ethernets:",
  #     "    ens18:", # **NOTE:** Adjust 'eth0' to your template's interface name (e.g., ens18)
  #     "      dhcp4: no",
  #     "EOF'",

  #     # Ensure the Netplan service has the correct permissions
  #     "sudo chmod 644 /etc/netplan/99-static-netcfg.yaml",

  #     # Final cleanup before template conversion
  #     "echo 'Agent installation and Netplan fix complete.'"
  #   ]
  # }

  # Clean up cloud-init state to prevent re-provisioning on clone/boot
  # Truncate machine-id so each cloned VM gets a new unique ID
  # provisioner "shell" {
  #   inline = [
  #     "echo 'Finalizing cleanup and preparing template...'",
  #     # Clean cloud-init state, remove logs, and unmount the config
  #     "sudo cloud-init clean --logs --seed",
  #     "sudo rm -rf /var/lib/cloud/*",

  #     # Truncate machine-id so each cloned VM gets a new unique ID
  #     "sudo truncate -s 0 /etc/machine-id",

  #     # Zero out empty space for better compression/storage use (optional but recommended)
  #     "sudo dd if=/dev/zero of=/EMPTY bs=1M || true",
  #     "sudo rm -f /EMPTY",

  #     "sudo sync",
  #     "echo 'Template ready!'"
  #   ]
  # }

}