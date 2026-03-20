# TrueNAS SCALE Infrastructure (Proxmox + Terraform)

This directory contains the Terraform configuration and modules required to deploy a **TrueNAS SCALE** Virtual Machine on a Proxmox VE host, featuring physical disk passthrough for ZFS storage.

## 🏗 Architecture Overview

- **Hypervisor:** Proxmox VE (PVE)
- **Provisioner:** Terraform (using the `bpg/proxmox` provider)
- **OS:** TrueNAS SCALE (Debian-based)
- **Resources:**
  - **CPU:** 2 Cores (Host type for AES-NI support)
  - **RAM:** 8 GB
  - **Boot Disk:** 32 GB Virtual Disk (SCSI 0)
  - **Data Disk:** Physical 1TB Seagate Drive (`/dev/disk/by-id/...`) mapped to SCSI 1.

## 🚀 Deployment Instructions

### 1. Prerequisites

- Identify the serial ID of your physical storage drive on the Proxmox host:
  ```bash
  ls -l /dev/disk/by-id/ | grep sdb
  ```
- Ensure your SSH Ed25519 public key is in the Proxmox host's `/root/.ssh/authorized_keys` file.

### 2. Infrastructure Provisioning

1.  Initialize the project:
    ```bash
    terraform init
    ```
2.  Set your `iso_file_id` in `terraform.tfvars` or the module call to point to your TrueNAS SCALE ISO.
3.  Apply the configuration:
    ```bash
    terraform apply
    ```
    _Note: The `null_resource.assign_passthrough_disk` will handle the physical disk attachment via SSH to bypass API restrictions._

### 3. Manual OS Installation

Once Terraform completes, open the Proxmox Console (noVNC) and follow these steps:

1.  **Select Destination:** Choose the **32 GB (scsi0)** drive for the OS. **Do not** select the 1TB drive.
2.  **Admin Account:** Create the administrative user (defaulting to `truenas_admin`).
3.  **Boot Mode:** Select **UEFI**.
4.  **Completion:** Once the installer finishes, shut down the VM.

### 4. Post-Installation Cleanup

Update your `main.tf` to eject the installation media:

```hcl
iso_file_id = "none"
```

Run `terraform apply` again to finalize the VM state.

## 🛠 Troubleshooting & Known Fixes

### "Matrix Mode" / Garbled Console

If the Proxmox console is unreadable during installation:

- Ensure the `vga` block is set to `type = "virtio"` with at least `128MB` of memory.
- If the issue persists, hit `e` at the GRUB boot menu and add `nomodeset` to the Linux boot line.

### Disk Passthrough Errors

The Proxmox API prevents non-root users from passing arbitrary filesystem paths. This code uses a `remote-exec` provisioner to execute `qm set` directly on the host as `root` to bypass this restriction.

## 📂 Module Structure

- `main.tf`: Defines the VM resource and hardware specs.
- `variables.tf`: Configuration for Disk IDs, Node names, and Network settings.
- `outputs.tf`: Exports the VM ID and assigned MAC address.
