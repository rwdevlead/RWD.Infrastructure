# apps/homarr

Deploys the Homarr homelab dashboard via Docker Compose on hosts in the `homarr` inventory group (`dev-docker-02`), exposed over HTTPS via Traefik.

---

## Requirements

- Docker Engine and Compose v2 (`docker/engine`, `docker/compose`)
- Traefik reverse proxy running on the external `traefik` Docker network
- Infisical secrets populated under `/ansible/homarr`

---

## Variables

### Role Defaults (`defaults/main.yml`)

| Variable | Description | Default |
| :--- | :--- | :--- |
| `homarr_version` | `ghcr.io/homarr-labs/homarr` image tag | `latest` |
| `homarr_base_dir` | Host directory for `docker-compose.yml` and `/appdata` mount | `"{{ docker_base_dir }}/{{ homarr.container }}"` |
| `homarr_config_dir` | Config subdirectory path variable | `"{{ homarr_base_dir }}/config"` |

### Group Variables (`inventories/group_vars/docker_hosts.yml`)

- `homarr`: `{ container: homarr-d02, domain: "homarr-d02.local.rwdevs.com", port: 7575 }`
- `shared_timezone`, `docker_base_dir`

---

## Infisical Secrets (`/ansible/homarr`)

| Secret Key | Description |
| :--- | :--- |
| `SECRET_ENCRYPTION_KEY` | Encryption key passed as `SECRET_ENCRYPTION_KEY` to Homarr |

---

## Dependencies

- `infisical_secrets` (invoked by `playbooks/homarr.yml`)
- `community.docker` collection

---

## Example

```yaml
- name: Deploy Homarr
  hosts: homarr
  become: true
  vars:
    infisical_secret_paths:
      - "/ansible/homarr"
  roles:
    - infisical_secrets
    - apps/homarr
```

---

## Make Targets

```bash
make homarr-check
make homarr
```

---

## Notes

- Mounts `{{ homarr_base_dir }}:/appdata` and `/var/run/docker.sock:/var/run/docker.sock:ro`, publishes `{{ homarr.port }}:7575`, and opts into Watchtower notifications.
- Renders `SECRET_ENCRYPTION_KEY` into `{{ homarr_base_dir }}/.env` (`mode: "0600"`, `diff: false`) and references `${SECRET_ENCRYPTION_KEY}` in `docker-compose.yml` (`mode: "0644"`).
- After starting the container, `tasks/main.yml` polls `https://{{ homarr.domain }}` (with `validate_certs: false`) until HTTP `200` is returned.
