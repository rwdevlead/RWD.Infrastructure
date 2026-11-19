# apps/nebula-sync

Deploys `nebula-sync` on `prod-docker-01` to synchronize configuration from the primary Pi-hole (`prod-docker-01`) to the replica Pi-hole (`dev-docker-02`) on an hourly schedule, sending status webhooks to Uptime Kuma.

---

## Requirements

- Docker Engine (`docker/engine`)
- Primary and replica Pi-hole instances reachable on port `8888` (`pihole`)
- Infisical secrets populated under `/ansible/pihole` and `/ansible/uptime_kuma`

---

## Variables

### Role Defaults (`defaults/main.yml`)

| Variable | Description | Default |
| :--- | :--- | :--- |
| `nebula_sync_image` | Nebula Sync Docker image | `"ghcr.io/lovelaze/nebula-sync:v0.11.2"` |
| `nebula_sync_base_dir` | Host directory for `docker-compose.yml` and `.env` | `"{{ docker_base_dir }}/nebula-sync"` |
| `nebula_sync_primary_token` | Primary Pi-hole API password | `"{{ secrets.ansible.pihole.PIHOLE_P01_PASSWORD }}"` |
| `nebula_sync_replica1_token` | Replica Pi-hole API password | `"{{ secrets.ansible.pihole.PIHOLE_D02_PASSWORD }}"` |

### Group Variables (`inventories/group_vars/docker_hosts.yml`)

| Variable | Description | Value |
| :--- | :--- | :--- |
| `nebula_sync_primary_node` | Primary Pi-hole base URL | `"http://{{ vms['prod-docker-01'].ip }}:8888"` |
| `nebula_sync_replica1_node` | Replica Pi-hole base URL | `"http://{{ vms['dev-docker-02'].ip }}:8888"` |
| `uptime_kuma_nebula_push_url_success` | Uptime Kuma push URL template on sync success | `"https://{{ uptime_kuma.domain }}/api/push/${NEBULA_PUSH_TOKEN}?status=up&msg=Sync+Success"` |
| `uptime_kuma_nebula_push_url_fail` | Uptime Kuma push URL template on sync failure | `"https://{{ uptime_kuma.domain }}/api/push/${NEBULA_PUSH_TOKEN}?status=down&msg=Sync+Failed"` |
| `shared_docker_network` | Docker network name | `"traefik"` |

---

## Infisical Secrets

| Path | Secret Key | Description |
| :--- | :--- | :--- |
| `/ansible/pihole` | `PIHOLE_P01_PASSWORD` | Primary Pi-hole API password |
| `/ansible/pihole` | `PIHOLE_D02_PASSWORD` | Replica Pi-hole API password |
| `/ansible/uptime_kuma` | `NEBULA_PUSH_TOKEN` | Uptime Kuma push monitor token for sync webhooks |

---

## Dependencies

- `infisical_secrets` (invoked by `playbooks/nebula_sync.yml`)
- `community.docker` collection

---

## Example

```yaml
- name: Deploy Nebula Sync Application
  hosts: prod-docker-01
  become: true
  vars:
    infisical_secret_paths:
      - "/ansible/pihole"
      - "/ansible/uptime_kuma"
  roles:
    - infisical_secrets
    - apps/nebula-sync
```

---

## Make Targets

```bash
make nebula-check
make nebula
```

---

## Notes

- Deploys `ghcr.io/lovelaze/nebula-sync:v0.11.2` via Docker Compose with `FULL_SYNC=true`, `RUN_GRAVITY=false`, `CRON="0 * * * *"`, and `TZ="{{ shared_timezone }}"`.
- Renders `NEBULA_SYNC_PRIMARY_TOKEN`, `NEBULA_SYNC_REPLICA1_TOKEN`, and `NEBULA_PUSH_TOKEN` into `{{ nebula_sync_base_dir }}/.env` (`mode: "0600"`, `diff: false`) and references them via `${...}` in `docker-compose.yml` (`mode: "0644"`).
- Individual `SYNC_CONFIG_*` and `SYNC_GRAVITY_*` flags are explicitly set to `"false"` because `FULL_SYNC="true"` is enabled.
