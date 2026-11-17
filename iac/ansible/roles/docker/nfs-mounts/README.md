# docker/nfs-mounts

Installs `nfs-common`, creates mount directories, mounts persistent TrueNAS NFS shares, and prepares `/mnt/docker/volumes` and `/mnt/docker/stacks`.

---

## Requirements

- Target host reachable in `docker_hosts`
- TrueNAS NFS exports created on `dev-truenas-01` (matching `nfs_mounts[].src`)

---

## Variables

### Role Defaults (`defaults/main.yml`)

| Variable | Description | Default |
| :--- | :--- | :--- |
| `nfs_mounts` | List of NFS mount definitions (`src`, `path`, `opts`) | Mounts `vms['dev-truenas-01'].ip:/mnt/tank/docker` to `/mnt/docker` and `/mnt/tank/backups` to `/mnt/backups` (`defaults,_netdev`) |

### Group Overrides (`inventories/group_vars/docker_hosts.yml`)

`docker_hosts.yml` overrides `nfs_mounts` for Docker hosts:

```yaml
nfs_mounts:
  - path: "/mnt/docker"
    src: "{{ vms['dev-truenas-01'].ip }}:/mnt/tank/docker/{{ inventory_hostname }}"
    opts: "rw,soft,intr"
```

---

## Infisical Secrets

None.

---

## Dependencies

- `vms['dev-truenas-01'].ip` from `iac/shared/infrastructure.yml` (loaded via `inventories/group_vars/all.yml`).

---

## Example

```yaml
- hosts: docker_hosts
  become: true
  roles:
    - docker/nfs-mounts
```

---

## Make Targets

```bash
make docker-check
make docker
```
