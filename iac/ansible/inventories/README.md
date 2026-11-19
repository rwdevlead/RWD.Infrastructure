# Ansible Inventories & Group Variables

Inventories and `group_vars/` live in `iac/ansible/inventories/`. Host IPs and VM/node metadata are not hardcoded here—they are read dynamically from [iac/shared/infrastructure.yml](../../shared/infrastructure.yml).

---

## Inventory Files

### [hosts.yml](hosts.yml)

Primary inventory for Docker hosts and the Proxmox cluster:

| Group | Hosts | `ansible_host` Source | Purpose |
| :--- | :--- | :--- | :--- |
| `docker_hosts` | `dev-docker-02`, `prod-docker-01` | `vms[host].ip` | Docker VMs managed for base, Docker, updates, Pi-hole, Watchtower |
| `portainer` | `dev-docker-02` | Inherited from `docker_hosts` | Primary Portainer server |
| `portainer_agents` | `prod-docker-01` | Inherited from `docker_hosts` | Remote Portainer agent nodes |
| `homarr` | `dev-docker-02` | Inherited from `docker_hosts` | Homarr dashboard host |
| `uptime_kuma` | `prod-docker-01` | Inherited from `docker_hosts` | Uptime Kuma monitoring host |
| `pulse` | `dev-docker-02` | Inherited from `docker_hosts` | Pulse Proxmox/Docker monitor host |
| `proxmox_cluster` | `pve-d01`, `pve-p01`, `proxmox` | `proxmox_nodes[host].ip` | Proxmox VE nodes for UPS/NUT orchestration |

### [truenas.yml](truenas.yml)

Dedicated inventory for TrueNAS storage automation (`make truenas` / `make truenas-check`):

| Group | Host | `ansible_host` Source | SSH Settings |
| :--- | :--- | :--- | :--- |
| `truenas_hosts` | `dev-truenas-01` | `vms['dev-truenas-01'].ip` | `ansible_user: truenas_admin`, `ansible_ssh_private_key_file: ~/.ssh/id_ed25519` |

---

## Group Variables (`group_vars/`)

### [group_vars/all.yml](group_vars/all.yml)

Applies to every host across all inventories. Dynamically loads `iac/shared/infrastructure.yml` via `lookup('ansible.builtin.file', inventory_dir ~ '/../../shared/infrastructure.yml') | from_yaml` and exports:
- `network` (`subnet`, `prefix`, `gateway`, `domain`)
- `proxmox_nodes` (`pve-d01`, `pve-p01`, `proxmox` with `alias` and `ip`)
- `vms` (`dev-truenas-01`, `prod-docker-01`, `homeassistant`, `dev-docker-02`, `dev-omv-01` with `vm_id`, `node`, `ip`)

### [group_vars/docker_hosts.yml](group_vars/docker_hosts.yml)

Configuration shared across `docker_hosts`:
- **System & Security:** `ansible_user: ka8kgj`, `shared_timezone`, `security_fail2ban_enabled`, `security_sysctl_enabled`, `security_firewall_enabled`, `ssh_port`.
- **Docker & Storage:** `shared_docker_api_version`, `shared_docker_network` (`traefik`), `docker_base_dir` (`/opt/docker`), `docker_base_mnt` (`/mnt/docker`), `docker_users`, and `nfs_mounts` (pointing to `vms['dev-truenas-01'].ip:/mnt/tank/docker/{{ inventory_hostname }}`).
- **Service Topology:** `pihole_instances`, `nebula_sync_*` (including `uptime_kuma_nebula_push_url_*` using `${NEBULA_PUSH_TOKEN}` interpolated via `nebula-sync/.env`), `traefik_instance`, `proxmox_instances`, `watchtower_instances`, `portainer_instance`, `portainer_agents`, `mailrise`, `truenas`, `homarr`, `homeassistant`, `uptime_kuma`, and `pulse_instance`.

### [group_vars/proxmox_cluster.yml](group_vars/proxmox_cluster.yml)

Configuration for `proxmox_cluster`:
- Sets `ansible_user: root`.
- Defines `nut_instances` keyed by `inventory_hostname` (`pve-d01` as UPS `master` with USB CyberPower config and Mailrise notification settings; `pve-p01` and `proxmox` as `slave` nodes with `poweroff_tier` and per-VM `shutdown_tier` / `wait_for_stop` metadata).

---

## Adding a New Host

1. Add the host's IP, `vm_id`, and `node` to [iac/shared/infrastructure.yml](../../shared/infrastructure.yml).
2. Add the host entry to [hosts.yml](hosts.yml) referencing `{{ vms['<name>'].ip }}` (or `proxmox_nodes`), and add it to the appropriate service groups.
3. Add any host-specific service metadata in `group_vars/docker_hosts.yml` (or `group_vars/proxmox_cluster.yml`) keyed by `inventory_hostname`.
