# apps/uptime_kuma

Deploys Uptime Kuma via Docker Compose on hosts in the `uptime_kuma` inventory group (`prod-docker-01`), with persistent NFS-backed storage and HTTPS routing via Traefik.

---

## Requirements

- Docker Engine and Compose v2 (`docker/engine`, `docker/compose`)
- External `traefik` Docker network and `/mnt/docker` NFS mount
- Traefik route configured for `{{ uptime_kuma.domain }}` (handled in `apps/traefik` `dynamic.yml.j2`)

---

## Variables

### Role Defaults (`defaults/main.yml`)

| Variable | Description | Default |
| :--- | :--- | :--- |
| `uptime_kuma_version` | `louislam/uptime-kuma` image tag | `2` |
| `uptime_kuma_base_dir` | Host directory for `docker-compose.yml` | `"{{ docker_base_dir }}/{{ uptime_kuma.container }}"` |
| `uptime_kuma_data_dir` | Persistent directory mounted to `/app/data` | `"{{ docker_base_mnt }}/{{ uptime_kuma.container }}"` |

### Group Variables (`inventories/group_vars/docker_hosts.yml`)

- `uptime_kuma`: `{ container: uptime-kuma-p01, domain: "uptime-kuma-p01.local.rwdevs.com", port: 3001 }`
- `shared_timezone`, `docker_base_dir`, `docker_base_mnt`

---

## Infisical Secrets

None required by this role (`apps/nebula-sync` uses `/ansible/uptime_kuma` → `NEBULA_PUSH_TOKEN` to push monitor updates to Uptime Kuma).

---

## Dependencies

- `community.docker` collection

---

## Example

```yaml
- name: Deploy Uptime Kuma
  hosts: uptime_kuma
  become: true
  roles:
    - role: apps/uptime_kuma
```

---

## Make Targets

```bash
make uptime-kuma-check
make uptime-kuma
```

---

## Notes

- Publishes `{{ uptime_kuma.port }}:3001`, configures `json-file` logging (`10m`, max `3`), healthchecks `http://localhost:3001`, and opts into Watchtower notifications.
- After deployment, `tasks/main.yml` polls `https://{{ uptime_kuma.domain }}` (with `validate_certs: false`) until HTTP `200` is returned.
