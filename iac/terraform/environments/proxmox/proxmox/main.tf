
locals {
  # trimspace removes trailing newlines that cause perpetual drift in some providers
  ssh_public_key_content  = trimspace(file("~/.ssh/id_ed25519.pub"))
  ssh_private_key_content = file("~/.ssh/id_ed25519")
}

module "ubuntu_template" {
  source        = "../../../modules/proxmox/template-ubuntu"
  vm_id         = 901
  vm_name       = "ubuntu-2404-template"
  node_name     = "proxmox"
  template_mode = false
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

module "Dev_Docker_01" {
  source = "../../../modules/proxmox/clone-vm"

  tempate_node_id   = module.ubuntu_template.template_id
  tempate_node_name = module.ubuntu_template.template_node_name

  vm_id          = local.infra.vms["dev-docker-01"].vm_id
  vm_node_name   = local.infra.vms["dev-docker-01"].node
  vm_name        = "dev-docker-01"
  vm_description = "Development Docker Instance"
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
  vm_static_ip         = "${local.infra.vms["dev-docker-01"].ip}/${local.infra.network.prefix}"
  network_device_model = "virtio"

  tags = ["vm", "dev", "docker"]

  ssh_public_key_content = local.ssh_public_key_content

}

module "homeassistant" {
  source = "../../../modules/proxmox/homeassistant"

  vm_id          = local.infra.vms["homeassistant"].vm_id
  node_name      = local.infra.vms["homeassistant"].node
  vm_name        = "homeassistant"
  vm_description = "Home Assistance Instance"
  vm_on_boot     = false

  vm_cores  = 2
  vm_memory = 4096

  efi_storage_id = "local-lvm"
  vm_os          = "l26"
  vm_bios        = "ovmf"
  vm_machine     = "q35"

  disk_interface  = "virtio0"
  disk_size       = 32
  disk_storage_id = "local-lvm"

  network_bridge = "vmbr0"

  tags = ["vm", "prod", "homeassistant"]

}

module "truenas_vm" {
  source            = "../../../modules/proxmox/truenas-vm"
  vm_name           = "dev-truenas-01"
  vm_id             = local.infra.vms["dev-truenas-01"].vm_id
  vm_description    = "TrueNAS SCALE - Managed by Terraform"
  vm_on_boot        = false
  proxmox_node_name = local.infra.vms["dev-truenas-01"].node
  proxmox_node_ip   = local.infra.proxmox_nodes["proxmox"].ip

  vm_cores = 2

  vm_bios    = "ovmf"
  vm_machine = "q35"

  vm_memory_max = 8192
  vm_memory_min = 8192

  boot_datastore = "local-lvm"
  iso_file_id    = "none"

  # Persistent /dev/disk/by-id identifier avoids drive-letter shifts across host reboots
  data_disk_id   = "ata-ST1000DM003-1ER162_Z4YCRN9L"
  disk_interface = "scsi0"
  disk_size      = 32

  network_gateway = local.infra.network.gateway
  vm_static_ip    = "${local.infra.vms["dev-truenas-01"].ip}/${local.infra.network.prefix}"

  tags = ["vm", "dev", "truenas"]

  ssh_private_key_content = local.ssh_private_key_content

}
