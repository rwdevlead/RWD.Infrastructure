output "vm_name" {
  description = "The name of the created VM"
  value       = proxmox_vm_qemu.vm.name
}

output "vm_id" {
  description = "The Proxmox VM ID"
  value       = proxmox_vm_qemu.vm.vm_id
}

output "vm_ip" {
  description = "IP address of the VM (if reported by QEMU agent)"
  value       = try(proxmox_vm_qemu.vm.default_ipv4_address, null)
}
