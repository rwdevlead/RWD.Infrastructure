# apps/pihole

Deploys Pi-hole v6 DNS and ad-blocking servers on `docker_hosts` via Docker Compose, with per-host configuration driven by `pihole_instances`.

---

## Requirements

- Docker Engine and Compose v2 (`docker/engine`, `docker/compose`)
- `systemd-resolved` stub listener disabled on port 53 (handled by `docker/engine`)
- TrueNAS NFS export `/mnt/tank/docker/{{ inventory_hostname }}` verified by `playbooks/pihole.yml` (`showmount -e`)
- Infisical secrets populated under `/ansible/pihole`

---

## Variables

### Role Defaults (`defaults/main.yml`)

| Variable | Description | Default |
| :--- | :--- | :--- |
| `pihole_image` | Pi-hole Docker image | `pihole/pihole:latest` |
| `pihole_base_dir` | Host directory for Compose file and volumes | `"{{ docker_base_dir }}/pihole"` |
| `pihole_dns1` | Primary upstream DNS server | `1.1.1.1` |
| `pihole_dns2` | Secondary upstream DNS server | `8.8.8.8` |
| `pihole_bind_dns` | Publish host ports `53/tcp`, `53/udp`, and `8888:80/tcp` | `true` |
| `pihole_watchtower_enable` | Add Watchtower notification label | `true` |

### Group Variables (`inventories/group_vars/docker_hosts.yml`)

- `pihole_instances[inventory_hostname]`: Defines `name`, `domain`, `url`, `server`, `container`, and `env_user_pwd` (`PIHOLE_P01_PASSWORD` for `prod-docker-01`, `PIHOLE_D02_PASSWORD` for `dev-docker-02`).
- `shared_docker_network`, `shared_timezone`, `docker_base_dir`.

---

## Infisical Secrets (`/ansible/pihole`)

| Secret Key | Description |
| :--- | :--- |
| `PIHOLE_P01_PASSWORD` | Web/API password (`FTLCONF_webserver_api_password`) for `prod-docker-01` |
| `PIHOLE_D02_PASSWORD` | Web/API password (`FTLCONF_webserver_api_password`) for `dev-docker-02` |

---

## Dependencies

- `infisical_secrets` (invoked by `playbooks/pihole.yml`)
- `community.docker` collection

---

## Example

```yaml
- name: Deploy Pi-hole
  hosts: docker_hosts
  become: true
  vars:
    infisical_secret_paths:
      - "/ansible/pihole"
  roles:
    - infisical_secrets
    - apps/pihole
```

---

## Make Targets

```bash
make pihole-check
make pihole
```

---

## Notes

- Publishes `53:53/tcp`, `53:53/udp`, and `8888:80/tcp` when `pihole_bind_dns` is `true` (port `8888` is used by `nebula-sync` and Traefik's `pihole-prod-service`), and attaches to `shared_docker_network` with Traefik HTTPS labels.
- Runs with `NET_ADMIN` capability and asserts container health (`pihole status | grep -q 'FTL is listening on port 53'`) after deployment.
- Renders `FTLCONF_webserver_api_password` into `{{ pihole_base_dir }}/.env` (`mode: "0600"`, `diff: false`) and references `"${FTLCONF_webserver_api_password}"` in `docker-compose.yml` (`mode: "0644"`).
- Do not run multiple Pi-hole containers on the same host, and do not proxy DNS (port 53) through Traefik.
