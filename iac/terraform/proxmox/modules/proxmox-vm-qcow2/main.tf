

# Step 1: Create the base VM (no disks yet)
resource "proxmox_vm_qemu" "vm" {
  name        = var.vm_name
  target_node = var.node_name
  cores       = var.cpu_cores
  memory      = var.memory_mb
  onboot      = var.start_on_boot
  agent       = 1
  scsihw      = "virtio-scsi-pci"
  bootdisk    = var.bootdisk
  boot        = "order=${var.bootdisk};net0"

  network {
    model  = "virtio"
    bridge = var.network_bridge
  }

  lifecycle {
    ignore_changes = [network]
  }
}

# Step 2: Import the QCOW2 disk
resource "null_resource" "import_disk" {
  triggers = {
    qcow2 = var.qcow2_path
    vm_id = proxmox_vm_qemu.vm.vm_id
  }

  provisioner "local-exec" {
    command = <<EOT
      set -e
      echo "Importing QCOW2 to VM ${self.triggers.vm_id}..."
      qm importdisk ${self.triggers.vm_id} ${self.triggers.qcow2} ${var.storage_pool} --format qcow2
    EOT
  }
}

# Step 3: Attach imported disk to the VM
resource "null_resource" "attach_disk" {
  depends_on = [null_resource.import_disk]

  triggers = {
    vm_id        = proxmox_vm_qemu.vm.vm_id
    storage_pool = var.storage_pool
    bootdisk     = var.bootdisk
  }

  provisioner "local-exec" {
    command = <<EOT
      set -e
      echo "Attaching imported disk to ${self.triggers.vm_id}..."
      qm set ${self.triggers.vm_id} --${self.triggers.bootdisk} ${self.triggers.storage_pool}:vm-${self.triggers.vm_id}-disk-0
    EOT
  }
}

# Step 4: Optionally resize disk
resource "null_resource" "resize_disk" {
  depends_on = [null_resource.attach_disk]

  count = var.disk_size_gb > 0 ? 1 : 0

  triggers = {
    vm_id = proxmox_vm_qemu.vm.vm_id
  }

  provisioner "local-exec" {
    command = "qm resize ${self.triggers.vm_id} ${var.bootdisk} ${var.disk_size_gb}G"
  }
}

# Step 5: Optionally start the VM
resource "null_resource" "start_vm" {
  depends_on = [
    proxmox_vm_qemu.vm,
    null_resource.attach_disk,
    null_resource.resize_disk
  ]

  count = var.start_vm ? 1 : 0

  provisioner "local-exec" {
    command = "qm start ${proxmox_vm_qemu.vm.vm_id}"
  }
}
