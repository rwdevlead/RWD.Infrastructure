# Ansible Roles

Roles under `iac/ansible/roles/` are grouped by infrastructure layer and application domain.

---

## Conventions

- **Variable Naming:** Role defaults in `defaults/main.yml` use a `<role>_*` prefix and hold role-level constants (ports, versions, paths, intervals)—never hardcoded hostnames or environment IPs.
- **Topology & Inventory:** Host-specific mappings live in `inventories/group_vars/` keyed by `inventory_hostname` and reference `iac/shared/infrastructure.yml` via `group_vars/all.yml`.
- **Secrets:** Roles never store credentials. Playbooks include `infisical_secrets` first and templates/tasks read `secrets.ansible.<path>.<KEY>`. Tasks writing credential-bearing files use `no_log: true` / `diff: false`.
- **Modules & Handlers:** Tasks use FQCN module names (`ansible.builtin.*`, `community.docker.*`). Handlers use capitalized descriptive names.
- **Documentation:** Every role category and role maintains a `README.md`.

---

## Role Index

### Vault & Secrets
| Role | Purpose | Docs |
| :--- | :--- | :--- |
| `infisical_secrets` | Fetches Infisical paths via `infisical.vault` and merges them into the `secrets` fact | [README](infisical_secrets/README.md) |

### Base System (`system_base/`)
Category overview: [system_base/README.md](system_base/README.md)

| Role | Purpose | Docs |
| :--- | :--- | :--- |
| `system_base/hostname` | Sets hostname, `/etc/hosts`, and timezone | [README](system_base/hostname/README.md) |
| `system_base/security` | Configures UFW firewall, fail2ban, and sysctl hardening | [README](system_base/security/README.md) |
| `system_base/ssh` | Hardens `sshd_config` (key-only auth, root login policy) | [README](system_base/ssh/README.md) |
| `system_base/users` | Creates admin users, groups, and authorized SSH keys | [README](system_base/users/README.md) |

### Docker Platform (`docker/`)
Category overview: [docker/README.md](docker/README.md)

| Role | Purpose | Docs |
| :--- | :--- | :--- |
| `docker/nfs-mounts` | Installs NFS client utilities and mounts persistent TrueNAS shares | [README](docker/nfs-mounts/README.md) |
| `docker/engine` | Installs Docker CE, configures daemon settings, and adds users to `docker` group | [README](docker/engine/README.md) |
| `docker/compose` | Creates standard `/opt/docker` directories and shared Docker bridge network | [README](docker/compose/README.md) |
| `docker/image_cleanup` | Prunes dangling/unused Docker images on `docker_hosts` | [README](docker/image_cleanup/README.md) |

### Proxmox Host Automation (`proxmox/`)
Category overview: [proxmox/README.md](proxmox/README.md)

| Role | Purpose | Docs |
| :--- | :--- | :--- |
| `proxmox/nut` | Configures NUT master/slave UPS monitoring, staged VM/host shutdown, and bring-up | [README](proxmox/nut/README.md) |

### TrueNAS Storage (`truenas/`)
Category overview: [truenas/README.md](truenas/README.md)

| Role | Purpose | Docs |
| :--- | :--- | :--- |
| `truenas/nas_config` | Creates ZFS pool, datasets, and NFS/SMB shares on TrueNAS | [README](truenas/nas_config/README.md) |

### Applications (`apps/`)
Category overview: [apps/README.md](apps/README.md)

| Role | Purpose | Docs |
| :--- | :--- | :--- |
| `apps/traefik` | Reverse proxy with Cloudflare DNS-01 TLS and dynamic file provider | [README](apps/traefik/README.md) |
| `apps/pihole` | Network DNS and ad-blocker (Pi-hole v6) | [README](apps/pihole/README.md) |
| `apps/nebula-sync` | Synchronizes primary and replica Pi-hole instances with Uptime Kuma push alerts | [README](apps/nebula-sync/README.md) |
| `apps/mailrise` | SMTP-to-notification relay gateway | [README](apps/mailrise/README.md) |
| `apps/portainer` | Primary Portainer container management UI | [README](apps/portainer/README.md) |
| `apps/portainer_agent` | Remote Portainer agent endpoint | [README](apps/portainer_agent/README.md) |
| `apps/homarr` | Homelab dashboard | [README](apps/homarr/README.md) |
| `apps/uptime_kuma` | Service uptime and push monitoring dashboard | [README](apps/uptime_kuma/README.md) |
| `apps/pulse` | Proxmox and Docker monitoring dashboard | [README](apps/pulse/README.md) |
| `apps/watchtower` | Automated container image update monitor | [README](apps/watchtower/README.md) |
