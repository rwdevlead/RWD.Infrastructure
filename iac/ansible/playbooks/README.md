# Ansible Playbooks

All playbooks live in `iac/ansible/playbooks/` and are mapped to `make <target>-check` and `make <target>` commands in the root [Makefile](../../../Makefile).

---

## Playbook Index

| Playbook | Target Hosts | Inventory | Roles / Tasks | Infisical Paths | Make Targets |
| :--- | :--- | :--- | :--- | :--- | :--- |
| [test_infisical.yml](test_infisical.yml) | `localhost` | Local (`-c local`) | `infisical_secrets` + assertions | `/`, `/shared`, `/ansible`, `/ansible/{cloudflare,homarr,homeassistant,mail,mailrise,pihole,portainer,watchtower}` | `make test-infisical` |
| [system_base.yml](system_base.yml) | `all` | `hosts.yml` | `system_base/hostname`, `system_base/security` (`users` & `ssh` commented out) | — | `make base-check` / `make base` |
| [system_updates.yml](system_updates.yml) | `docker_hosts` *(Makefile limits to `dev-docker-02`)* | `hosts.yml` | Inline tasks (`unattended-upgrades`, `postfix` → Mailrise, `nfs-common`/`cifs-utils`, `manual_upgrade` dist-upgrade + reboot) | — | `make setup-updates`, `make run-upgrade` |
| [docker.yml](docker.yml) | `docker_hosts` *(`make docker` limits to `dev-docker-02 -v`)* | `hosts.yml` | `system_base/hostname`, `docker/nfs-mounts`, `docker/engine`, `docker/compose` | — | `make docker-check` / `make docker` |
| [docker_image_cleanup.yml](docker_image_cleanup.yml) | `docker_hosts` | `hosts.yml` | `docker/image_cleanup` | — | `make docker-cleanup-check` / `make docker-cleanup` |
| [traefik.yml](traefik.yml) | `dev-docker-02` | `hosts.yml` | `infisical_secrets`, `apps/traefik`, `docker/image_cleanup` | `/ansible/cloudflare` | `make traefik-check` / `make traefik` |
| [mailrise.yml](mailrise.yml) | `prod-docker-01` | `hosts.yml` | `infisical_secrets`, `apps/mailrise`, `docker/image_cleanup` | `/ansible/mail`, `/ansible/mailrise` | `make mailrise-check` / `make mailrise` |
| [pihole.yml](pihole.yml) | `docker_hosts` | `hosts.yml` | `showmount -e` pre-task, `infisical_secrets`, `apps/pihole`, `docker/image_cleanup` | `/ansible/pihole` | `make pihole-check` / `make pihole` |
| [nebula_sync.yml](nebula_sync.yml) | `prod-docker-01` | `hosts.yml` | `infisical_secrets`, `apps/nebula-sync` | `/ansible/pihole`, `/ansible/uptime_kuma` | `make nebula-check` / `make nebula` |
| [portainer.yml](portainer.yml) | `dev-docker-02` | `hosts.yml` | `infisical_secrets`, `apps/portainer` | `/ansible/portainer` | `make portainer-check` / `make portainer` |
| [portainer_agent.yml](portainer_agent.yml) | `portainer_agents` | `hosts.yml` | `infisical_secrets`, `apps/portainer_agent` | `/ansible/portainer` | `make portainer-agent-check` / `make portainer-agent` |
| [homarr.yml](homarr.yml) | `homarr` | `hosts.yml` | `infisical_secrets`, `apps/homarr` | `/ansible/homarr` | `make homarr-check` / `make homarr` |
| [uptime_kuma.yml](uptime_kuma.yml) | `uptime_kuma` | `hosts.yml` | `apps/uptime_kuma` | — | `make uptime-kuma-check` / `make uptime-kuma` |
| [pulse.yml](pulse.yml) | `pulse` | `hosts.yml` | `apps/pulse` | — | `make pulse-check` / `make pulse` |
| [watchtower.yml](watchtower.yml) | `docker_hosts` | `hosts.yml` | `infisical_secrets`, `apps/watchtower`, `docker/image_cleanup` | `/ansible/watchtower` | `make watchtower-check` / `make watchtower` |
| [deploy_nas_storage.yml](deploy_nas_storage.yml) | `truenas_hosts` | `truenas.yml` | `truenas/nas_config` (`gather_facts: false`, inline `pool_name`/`datasets`) | — | `make truenas-check` / `make truenas` |
| [nut.yml](nut.yml) | `proxmox_cluster` | `hosts.yml` | `infisical_secrets`, `proxmox/nut` | `/ansible/nut` | `make ups-nut-check` / `make ups-nut` |

---

## Notable Playbook Details

- **`system_updates.yml`:** Does not use a role. Installs `nfs-common`/`cifs-utils`, configures `unattended-upgrades` (auto-reboot at `03:00`) and Postfix relay to `prod-docker-01` Mailrise, and exposes the `manual_upgrade` tag (with `never`) for full `apt dist-upgrade` + conditional reboot via `make run-upgrade`. Both `make setup-updates` and `make run-upgrade` currently pass `--limit dev-docker-02`.
- **`docker.yml`:** `make docker-check` evaluates all `docker_hosts`, whereas `make docker` passes `--limit dev-docker-02 -v`.
- **`pihole.yml`:** Runs a `pre_tasks` check (`showmount -e {{ vms['dev-truenas-01'].ip }}`) with `check_mode: false` and aborts if `/mnt/tank/docker/{{ inventory_hostname }}` is not exported.
- **`system_base.yml`:** `system_base/users` and `system_base/ssh` are currently commented out in the playbook's `roles:` list.
- **`deploy_nas_storage.yml`:** Runs with `gather_facts: false` against `inventories/truenas.yml` and defines `pool_name`, `data_disk`, `wipe_existing_pool`, and `datasets` inline.
- **`test_infisical.yml`:** Runs locally (`-c local`) to validate `infisical_secrets` path loading, top-level `/` promotion, and nested/bracket key access.
