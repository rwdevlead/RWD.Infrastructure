# TrueNAS SCALE VM Module (Proxmox)

This module provisions the hardware "shell" for a TrueNAS SCALE appliance on Proxmox.

## Scope

- **Terraform:** Manages CPU, RAM, Boot Disk (32GB), and Physical Disk Passthrough.
- **Manual:** OS Installation via ISO and initial Network/SSL setup via Web UI.
- **Ansible:** Manages ZFS Pools, Datasets, and SMB/NFS Shares.

## Requirements

- Proxmox VE with SSH enabled for root.
- A physical disk ID from `/dev/disk/by-id/` for data storage.
- A functional TrueNAS SCALE ISO in a Proxmox storage pool.

## Key Logic: Disk Passthrough

Because the Proxmox API occasionally restricts raw disk mapping, this module uses a `null_resource` with `remote-exec` to run the `qm set` command directly on the Proxmox host.

## Inputs

| Name             | Description                                          | Default     |
| ---------------- | ---------------------------------------------------- | ----------- |
| `vm_id`          | Unique Proxmox VM ID                                 | N/A         |
| `data_disk_id`   | The ID of the physical drive (e.g., `ata-ST1000...`) | N/A         |
| `boot_datastore` | Proxmox storage for the OS                           | `local-lvm` |

## Usage

After `terraform apply`, access the Proxmox console to complete the TrueNAS installation. Set the Static IP and SSL certificates via the TrueNAS Web UI to ensure they are saved to the internal configuration database.

## Provisioning Workflow

1. **Terraform:** Creates VM shell and handles physical disk passthrough (`qm set`).
2. **Manual:** OS installation and Web UI network/SSL setup.
3. **Pi-hole:** Map `truenas.local.rwdevs.com` to the static IP.
4. **Ansible:** Configure ZFS pools, datasets, and shares.

## Networking Note

This module does not inject networking via Cloud-Init to avoid conflicts with the TrueNAS configuration database. Static IPs must be set manually in the TrueNAS UI.
