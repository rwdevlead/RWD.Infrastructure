Perfect — here’s a README.md summary you can drop into your repo. It explains the end-to-end workflow: Packer → cloud-init → Terraform → Proxmox, with Makefile automation.

⸻

README.md

# Proxmox Ubuntu VM Automation

This repository provides a fully automated workflow to build **Ubuntu 24.04 cloud-init templates** with **Packer**, and deploy VMs from those templates using **Terraform** on a **Proxmox** server.

It also includes a **Makefile** to streamline building and deploying VMs.

---

## Directory Structure

root/
├─ iac/
│ ├─ packer/
│ │ └─ ubuntu/ # Packer template files
│ │ ├─ ubuntu-template.pkr.hcl
│ │ └─ files/
│ │ └─ 99-pve.cfg # Proxmox cloud-init config
│ └─ terraform/
│ └─ proxmox/ # Terraform module & vars
│ ├─ main.tf
│ ├─ variables.tf
│ ├─ outputs.tf
│ ├─ cloudinit.yaml.tpl # Cloud-init template for VM deployment
│ └─ terraform.tfvars # Default variables including SSH key
├─ Makefile # Root Makefile for automation

---

## Prerequisites

- Packer >= 1.9
- Terraform >= 1.5
- Proxmox server with API access
- Local SSH key at `~/.ssh/id_rsa.pub` (used by default)
- Ubuntu 24.04 ISO available in Proxmox storage

---

## Packer: Build Ubuntu Cloud-Init Template

The Packer template builds a **base Ubuntu 24.04 VM** ready for Proxmox cloud-init:

```bash
# Validate the template
make packer-validate

# Build the template
make packer-build

# Clean temporary files
make packer-clean

Notes:
	•	The template installs qemu-guest-agent for Proxmox integration.
	•	The 99-pve.cfg file ensures proper cloud-init behavior inside Proxmox.
	•	Docker installation is commented out by default in cloud-init; you can enable it later.

⸻

Terraform: Deploy VMs from Template

Terraform module uses the Packer-built template to deploy VMs with cloud-init configuration:

# Initialize Terraform
make terraform-init

# Review changes
make terraform-plan

# Deploy VM
make terraform-apply

# Destroy VM if needed
make terraform-destroy

Cloud-Init Integration
	•	Cloud-init reads SSH keys, hostname, and network configuration from Terraform variables.
	•	Default user is ubuntu with sudo privileges.
	•	SSH key is pulled automatically from ~/.ssh/id_rsa.pub:

ssh_public_key = file("~/.ssh/id_rsa.pub")

	•	Optional Docker installation is included in the cloud-init template but commented out.

⸻

Terraform Variables (terraform.tfvars)

Default values:

hostname      = "ubuntu-vm01"
node          = "proxmox"
template_name = "ubuntu-24.04-cloudinit"
cpu_cores     = 2
memory_mb     = 4096
disk_size     = "20G"
bridge        = "vmbr0"
ssh_public_key = file("~/.ssh/id_rsa.pub")

	•	Customize these variables per deployment.

⸻

Makefile Targets

Target	Description
packer-validate	Validate the Packer template
packer-build	Build the Ubuntu cloud-init template
packer-clean	Remove Packer temporary files
terraform-init	Initialize Terraform module
terraform-plan	Preview Terraform changes
terraform-apply	Apply Terraform deployment
terraform-destroy	Destroy Terraform-managed VM


⸻

Workflow Summary
	1.	Build Packer template
	•	Generates a cloud-init-ready Ubuntu template for Proxmox.
	2.	Terraform module
	•	Clones the template, injects SSH key, sets hostname, CPU, memory, disk, and network.
	3.	VM boots
	•	ubuntu user created with SSH key access.
	•	QEMU guest agent enabled for Proxmox integration.
	4.	Optional post-deploy
	•	Docker or other software can be installed via cloud-init or provisioning scripts.

⸻

Notes & Best Practices
	•	Do not bake your SSH keys into Packer templates. Use Terraform variables for security.
	•	Keep Docker installation commented in template; enable only per-deployment.
	•	Use Makefile to orchestrate builds and deployments consistently.
	•	Templates are reusable and can be cloned multiple times for multiple VMs.

---

If you like, I can also **add a diagram showing the full flow** (Packer → Proxmox template → Terraform → VM), which makes the README even clearer.

Do you want me to do that next?
```
