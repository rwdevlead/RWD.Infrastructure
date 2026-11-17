output "vm_ipv4_address" {
  description = "The assigned IPv4 address of the cloned VM."
  # Index [0] is the loopback interface (127.0.0.1); [1][0] returns the primary LAN interface IP
  value = can(proxmox_virtual_environment_vm.ubuntu_clone.ipv4_addresses[1][0]) ? (
    proxmox_virtual_environment_vm.ubuntu_clone.ipv4_addresses[1][0]
    ) : (
    "VM is powered off or IP not yet assigned"
  )
}
