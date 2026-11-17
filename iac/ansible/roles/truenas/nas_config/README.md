# truenas/nas_config

Provisions a ZFS pool on a target block device, creates nested ZFS datasets, and enables `nfs-server` and `smbd` systemd services on TrueNAS SCALE.

---

## Requirements

- TrueNAS host defined in [inventories/truenas.yml](../../../inventories/truenas.yml) (`truenas_hosts`)
- Passwordless/key SSH access as `truenas_admin` with `sudo` (`become: true`)
- Target data disk present on the TrueNAS VM (e.g., `/dev/sdb`)

---

## Variables

All variables are supplied by [playbooks/deploy_nas_storage.yml](../../../playbooks/deploy_nas_storage.yml) (there is no `defaults/main.yml`):

| Variable | Description | Playbook Value |
| :--- | :--- | :--- |
| `pool_name` | Name of the ZFS pool to create (mounted with `-o altroot=/mnt`) | `"tank"` |
| `data_disk` | Block device path for the ZFS pool | `"/dev/sdb"` |
| `wipe_existing_pool` | Destroy existing pool matching `pool_name` before recreating | `false` |
| `datasets` | List of datasets (`{ path, type }`, where `type` is `nfs` or `smb`) | `tank/iso`, `tank/backups` (`nfs`); `tank/media/{music,pictures,video,software}`, `tank/documents` (`smb`) |

---

## Infisical Secrets

None.

---

## Dependencies

None (`playbooks/deploy_nas_storage.yml` runs with `gather_facts: false`).

---

## Example

```yaml
- name: Configure TrueNAS Storage
  hosts: truenas_hosts
  gather_facts: false
  become: true
  vars:
    pool_name: "tank"
    data_disk: "/dev/sdb"
    wipe_existing_pool: false
    datasets:
      - { path: "tank/iso", type: "nfs" }
      - { path: "tank/backups", type: "nfs" }
  roles:
    - truenas/nas_config
```

---

## Make Targets

```bash
make truenas-check
make truenas
```

---

## Notes

- > [!CAUTION]
  > When `wipe_existing_pool` is `true`, the role runs `zpool destroy -f {{ pool_name }}`. Whenever `pool_name` does not already exist, it cleans LVM/ZFS/MD RAID signatures, runs `wipefs -a -f`, and zeros the start of `data_disk` before creating the pool.
- Enables `nfs-server` when any dataset has `type: "nfs"` and `smbd` when any dataset has `type: "smb"`.
- Dataset NFS exports and SMB share ACLs/exports beyond `zfs create -p` and service enablement are managed in the TrueNAS UI (for example `/mnt/tank/docker/<host>` required by `pihole.yml`).
