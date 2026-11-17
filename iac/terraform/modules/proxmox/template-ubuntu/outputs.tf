output "template_id" {
  description = "Proxmox VM ID of the Ubuntu template"
  value       = proxmox_virtual_environment_vm.template.vm_id
}

output "template_node_name" {
  description = "Proxmox node hosting the Ubuntu template"
  value       = proxmox_virtual_environment_vm.template.node_name
}
