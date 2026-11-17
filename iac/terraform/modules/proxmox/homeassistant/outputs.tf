output "vm_id" {
  description = "The ID of the Home Assistant VM"
  value       = proxmox_virtual_environment_vm.home_assistant.vm_id
}

output "vm_name" {
  description = "The name of the VM"
  value       = proxmox_virtual_environment_vm.home_assistant.name
}
