# Docker Platform Roles (`docker/`)

Roles under `iac/ansible/roles/docker/` configure NFS-backed persistent storage, Docker Engine, and Docker Compose on `docker_hosts`.

---

## Roles & Execution Order

[playbooks/docker.yml](../../playbooks/docker.yml) runs on `docker_hosts` in this order:

1. [`system_base/hostname`](../system_base/hostname/README.md) — Ensures consistent hostname and `/etc/hosts`
2. [`docker/nfs-mounts`](nfs-mounts/README.md) — Mounts TrueNAS NFS shares (`/mnt/docker`) and creates `/mnt/docker/{volumes,stacks}`
3. [`docker/engine`](engine/README.md) — Installs Docker CE + plugins, adds systemd NFS dependency, adds `docker_users` to `docker`, and disables `systemd-resolved` stub listener
4. [`docker/compose`](compose/README.md) — Ensures `docker-compose-plugin` is installed and creates the external `traefik` bridge network

---

## Shared Group Variables

Defined in [inventories/group_vars/docker_hosts.yml](../../inventories/group_vars/docker_hosts.yml):
- `docker_base_dir`: `/opt/docker`
- `docker_base_mnt`: `/mnt/docker`
- `shared_docker_network`: `traefik`
- `shared_docker_api_version`: `"1.52"`
- `docker_users`: `["ka8kgj"]`
- `nfs_mounts`: Mounts `vms['dev-truenas-01'].ip:/mnt/tank/docker/{{ inventory_hostname }}` at `/mnt/docker`

---

## Make Targets

```bash
# Dry-run across all docker_hosts
make docker-check

# Deploy Docker platform (Makefile currently limits to dev-docker-02 with -v)
make docker
```
