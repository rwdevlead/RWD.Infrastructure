output "vm_id" {
  description = "The ID of the Home Assistant VM"
  value       = proxmox_virtual_environment_vm.home_assistant.vm_id
}

output "vm_name" {
  description = "The name of the VM"
  value       = proxmox_virtual_environment_vm.home_assistant.name
}

# This extracts the first IPv4 address found by the guest agent
# output "ha_ipv4_address" {
#   description = "The primary IPv4 address of the Home Assistant instance"
#   value       = flatten(proxmox_virtual_environment_vm.home_assistant.ipv4_addresses)[1]
#   # Note: Index [1] is often the actual IP, while [0] is usually the loopback (127.0.0.1)
# }

# output "ha_dashboard_url" {
#   description = "The URL to access the Home Assistant dashboard"
#   value       = "http://${flatten(proxmox_virtual_environment_vm.home_assistant.ipv4_addresses)[1]}:8123"
# }
