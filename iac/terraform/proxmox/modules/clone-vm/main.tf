
terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      # version = "0.89.1" # version = ">=0.66"
    }
  }
}

data "proxmox_virtual_environment_vm" "template_vm" {
  vm_id     = var.tempate_node_id
  node_name = var.tempate_node_name
}


resource "proxmox_virtual_environment_vm" "ubuntu_clone" {
  name      = var.vm_name
  node_name = var.vm_node_name

  description = var.vm_description

  clone {
    vm_id = data.proxmox_virtual_environment_vm.template_vm.id
    full  = true
  }

  agent {
    # NOTE: The agent is installed and enabled as part of the cloud-init configuration in the template VM, see cloudinit.yaml
    # The working agent is *required* to retrieve the VM IP addresses.
    # If you are using a different cloud-init configuration, or a different clone source
    # that does not have the qemu-guest-agent installed, you may need to disable the `agent` below and remove the `vm_ipv4_address` output.
    # See https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_vm#qemu-guest-agent for more details.
    enabled = true
  }

  on_boot = true


  cpu {
    type  = "x86-64-v2-AES"
    cores = var.vm_cores
  }

  machine = var.vm_machine

  operating_system {
    type = var.vm_os
  }

  memory {
    dedicated = var.vm_memory_max
    floating  = var.vm_memory_min
  }

  bios = var.vm_bios

  efi_disk {
    datastore_id = var.efi_storage_id
    type         = "4m"
  }

  disk {
    interface    = var.disk_interface
    iothread     = true
    size         = var.disk_size
    datastore_id = var.disk_storage_id
  }

  network_device {
    model = var.network_device_model
  }


  initialization {


    user_account {
      keys     = [var.ssh_public_key_content]
      username = "ka8kgj"
      password = "password123"
    }

    dns {
      servers = [var.network_gateway, "1.1.1.1"]
    }
    ip_config {
      ipv4 {
        address = var.vm_static_ip
        gateway = var.network_gateway
      }
    }

  }

  keyboard_layout = var.keyboard

  tags = var.tags

}


