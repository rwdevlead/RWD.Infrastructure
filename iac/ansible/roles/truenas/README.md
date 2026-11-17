# TrueNAS Storage Roles (`truenas/`)

Roles under `iac/ansible/roles/truenas/` automate storage configuration on TrueNAS SCALE (`dev-truenas-01`).

---

## Roles

| Role | Purpose |
| :--- | :--- |
| [`truenas/nas_config`](nas_config/README.md) | Creates ZFS pool, ZFS datasets, and enables `nfs-server` / `smbd` services |

---

## Make Targets

```bash
# Dry-run TrueNAS storage configuration (inventories/truenas.yml)
make truenas-check

# Apply TrueNAS storage configuration
make truenas
```
