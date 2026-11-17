# Proxmox Host Automation Roles (`proxmox/`)

Roles under `iac/ansible/roles/proxmox/` configure Proxmox VE hypervisor nodes in the `proxmox_cluster` inventory group (`pve-d01`, `pve-p01`, `proxmox`).

---

## Roles

| Role | Purpose |
| :--- | :--- |
| [`proxmox/nut`](nut/README.md) | Configures Network UPS Tools (`nut-server`/`nut-client`), staged VM/host takedown on battery depletion, and automated boot-time bring-up |

---

## Inventory & Shared Topology

- Target hosts: `proxmox_cluster` in [inventories/hosts.yml](../../inventories/hosts.yml)
- Node connection & UPS/VM shutdown topology: [inventories/group_vars/proxmox_cluster.yml](../../inventories/group_vars/proxmox_cluster.yml) (`ansible_user: root`, `nut_instances`)
- Node aliases/IPs and VM IDs/IPs: [iac/shared/infrastructure.yml](../../../shared/infrastructure.yml)

---

## Make Targets

```bash
# Dry-run NUT cluster configuration
make ups-nut-check

# Deploy NUT cluster configuration
make ups-nut
```
