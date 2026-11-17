
locals {
  # trimspace removes trailing newlines that cause perpetual drift in some providers
  ssh_public_key_content  = trimspace(file("~/.ssh/id_ed25519.pub"))
  ssh_private_key_content = file("~/.ssh/id_ed25519")
}

module "ubuntu_template" {
  source        = "../../../modules/proxmox/template-ubuntu"
  vm_id         = 801
  vm_name       = "ubuntu-2404-template"
  node_name     = "pve-p01"
  template_mode = true
  vm_startup    = false

  efi_storage_id = "local-lvm"
  vm_bios        = "ovmf"
  vm_machine     = "q35"
  vm_memory      = 4096
  vm_os          = "l26"

  network_bridge = "vmbr0"

  disk_size       = 20
  disk_interface  = "virtio0"
  disk_storage_id = "local-lvm"

  iso_target             = "local"
  iso_checksum           = "d8f7f427a53c221feee90d47ca008d89237e206a2d4935c98b84eefdbf52f41d"
  iso_url                = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
  iso_checksum_algorithm = "sha256"

  tags = ["template", "linux"]

  ssh_public_key_content = local.ssh_public_key_content

}

module "Prod_Docker_01" {
  source = "../../../modules/proxmox/clone-vm"

  tempate_node_id   = module.ubuntu_template.template_id
  tempate_node_name = module.ubuntu_template.template_node_name

  vm_id          = local.infra.vms["prod-docker-01"].vm_id
  vm_node_name   = local.infra.vms["prod-docker-01"].node
  vm_name        = "prod-docker-01"
  vm_description = "Production Docker Instance"
  vm_on_boot     = false

  vm_username = var.default_username
  vm_password = var.default_password

  vm_cores = 2

  efi_storage_id = "local-lvm"
  vm_os          = "l26"
  vm_bios        = "ovmf"
  vm_machine     = "q35"

  vm_memory_max = 8192
  vm_memory_min = 4096

  disk_interface  = "virtio0"
  disk_size       = 40
  disk_storage_id = "local-lvm"

  network_gateway      = local.infra.network.gateway
  vm_static_ip         = "${local.infra.vms["prod-docker-01"].ip}/${local.infra.network.prefix}"
  network_device_model = "virtio"

  tags = ["vm", "prod", "docker"]

  ssh_public_key_content = local.ssh_public_key_content

}

module "omv_vm" {
  source            = "../../../modules/proxmox/omv-vm"
  vm_name           = "dev-omv-01"
  vm_id             = local.infra.vms["dev-omv-01"].vm_id
  vm_description    = "Open Media Vault - Managed by Terraform"
  vm_on_boot        = false
  proxmox_node_name = local.infra.vms["dev-omv-01"].node
  proxmox_node_ip   = local.infra.proxmox_nodes["pve-p01"].ip

  vm_cores = 2

  vm_bios    = "ovmf"
  vm_machine = "q35"

  # Pin 4 GiB min/max to keep OMV memory within the host's 3-4 GiB allocation target
  vm_memory_max = 4096
  vm_memory_min = 4096

  boot_datastore = "local-lvm"
  iso_file_id    = "none"

  # Persistent /dev/disk/by-id identifier avoids drive-letter shifts across host reboots
  data_disk_id   = "ata-HGST_HTS541010A9E680_JA1009C033492P"
  disk_interface = "scsi0"
  disk_size      = 32

  network_gateway = local.infra.network.gateway
  vm_static_ip    = "${local.infra.vms["dev-omv-01"].ip}/${local.infra.network.prefix}"

  tags = ["vm", "dev", "omv", "storage"]

  ssh_private_key_content = local.ssh_private_key_content

}
