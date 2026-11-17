# apps/portainer

Deploys the primary Portainer CE server via Docker Compose on `dev-docker-02`, exposed over HTTPS via Traefik.

---

## Requirements

- Docker Engine and Compose v2 (`docker/engine`, `docker/compose`)
- External Docker network (`shared_docker_network`, default `traefik`)
- Infisical secrets populated under `/ansible/portainer`

---

## Variables

### Role Defaults (`defaults/main.yml`)

| Variable | Description | Default |
| :--- | :--- | :--- |
| `portainer_image` | Docker image repository | `"portainer/portainer-ce"` |
| `portainer_tag` | Docker image tag | `"latest"` |
| `portainer_base_dir` | Host directory for `docker-compose.yml` | `"{{ docker_base_dir }}/{{ portainer_instance.container }}"` |
| `portainer_data_dir` | Persistent data directory mounted to `/data` | `"{{ docker_base_mnt }}/{{ portainer_instance.container }}"` |
| `portainer_watchtower_enable` | Watchtower label value | `"true"` |
| `portainer_healthcheck_interval` | Container healthcheck interval | `"30s"` |
| `portainer_healthcheck_timeout` | Container healthcheck timeout | `"10s"` |
| `portainer_healthcheck_retries` | Container healthcheck retries | `3` |
| `portainer_session_timeout` | Admin UI session timeout (hours) | `24` |
| `portainer_agent_secret` | Shared Portainer Agent auth secret | `"{{ secrets.ansible.portainer.AGENT_SECRET }}"` |

### Group Variables (`inventories/group_vars/docker_hosts.yml`)

- `portainer_instance`: `{ url: "https://portainer-d02.local.rwdevs.com", container: portainer-d02, domain: portainer-d02.local.rwdevs.com }`
- `shared_docker_network`, `docker_base_dir`, `docker_base_mnt`

---

## Infisical Secrets (`/ansible/portainer`)

| Secret Key | Description |
| :--- | :--- |
| `AGENT_SECRET` | Shared secret used to authenticate connections to `apps/portainer_agent` nodes |

---

## Dependencies

- `infisical_secrets` (invoked by `playbooks/portainer.yml`)
- `community.docker` collection

---

## Example

```yaml
- name: Deploy Portainer
  hosts: dev-docker-02
  become: true
  vars:
    infisical_secret_paths:
      - "/ansible/portainer"
  roles:
    - infisical_secrets
    - apps/portainer
```

---

## Make Targets

```bash
make portainer-check
make portainer
```

---

## Notes

- Runs `community.docker.docker_compose_v2` with `pull: always` and does not publish host ports directly; UI access is routed through Traefik at `https://portainer-d02.local.rwdevs.com` (port `9000` internal).
- Sets `SKIP_TLS_CERT_VERIFICATION=true` to simplify internal endpoint communication.
