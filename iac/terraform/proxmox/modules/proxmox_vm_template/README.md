summarize the create repo module

# Terraform Module: Proxmox VM

This module creates a virtual machine in Proxmox using a cloud-init–ready template.

## Example Usage

```hcl
module "ubuntu_vm" {
  source = "./modules/proxmox-vm"

  proxmox_endpoint     = "https://proxmox.local:8006/api2/json"
  proxmox_token_id     = "terraform@pve!mytoken"
  proxmox_token_secret = "supersecret"
  node_name            = "pve01"
  vm_name              = "ubuntu-docker"
  clone_template       = "ubuntu-22.04-cloudinit"
  storage_pool         = "local-lvm"
  ip_address           = "192.168.1.100/24"
  gateway              = "192.168.1.1"
  ssh_public_key       = file("~/.ssh/id_rsa.pub")
}
```
