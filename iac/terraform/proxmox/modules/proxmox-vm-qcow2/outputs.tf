output "vm_id" {
  description = "The Proxmox VM ID"
  value       = proxmox_vm_qemu.vm.vm_id
}

output "vm_name" {
  description = "The name of the VM"
  value       = proxmox_vm_qemu.vm.name
}

output "node_name" {
  description = "The Proxmox node where the VM resides"
  value       = proxmox_vm_qemu.vm.target_node
}
