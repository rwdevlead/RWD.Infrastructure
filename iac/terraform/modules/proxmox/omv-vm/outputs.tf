output "vm_ipv4_address" {
  description = "The assigned IPv4 address of the OMV VM."
  value = can(proxmox_virtual_environment_vm.omv.ipv4_addresses[1][0]) ? (
    proxmox_virtual_environment_vm.omv.ipv4_addresses[1][0]
    ) : (
    "VM is powered off or IP not yet assigned"
  )
}

output "vm_id" {
  description = "The ID of the OMV VM."
  value       = proxmox_virtual_environment_vm.omv.vm_id
}
