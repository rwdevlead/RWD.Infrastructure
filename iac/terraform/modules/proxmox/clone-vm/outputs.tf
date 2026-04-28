# TODO output "vm_ipv4_address" {
#   value = proxmox_virtual_environment_vm.ubuntu_clone.ipv4_addresses[1][0]
# }
output "vm_ipv4_address" {
  description = "The assigned IPv4 address of the cloned VM."
  value = can(proxmox_virtual_environment_vm.ubuntu_clone.ipv4_addresses[1][0]) ? (
    proxmox_virtual_environment_vm.ubuntu_clone.ipv4_addresses[1][0]
    ) : (
    "VM is powered off or IP not yet assigned"
  )
}
