output "vm_id" {
  value       = proxmox_vm_qemu.vm.id
  description = "ID of the deployed VM"
}

output "vm_name" {
  value       = proxmox_vm_qemu.vm.name
  description = "Name of the deployed VM"
}

output "vm_node" {
  value       = proxmox_vm_qemu.vm.node
  description = "Proxmox node the VM is deployed on"
}
