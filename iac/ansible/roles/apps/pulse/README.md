# apps/pulse

Deploys Pulse (Proxmox and Docker monitoring dashboard) via Docker Compose on hosts in the `pulse` inventory group (`dev-docker-02`), exposed over HTTPS via Traefik.

---

## Requirements

- Docker Engine and Compose v2 (`docker/engine`, `docker/compose`)
- External `traefik` Docker network and `/mnt/docker` NFS mount

---

## Variables

### Role Defaults (`defaults/main.yml`)

| Variable | Description | Default |
| :--- | :--- | :--- |
| `pulse_image` | Docker image repository | `"rcourtman/pulse"` |
| `pulse_tag` | Docker image tag | `latest` |
| `pulse_base_dir` | Host directory for `docker-compose.yml` | `"{{ docker_base_dir }}/{{ pulse_instance.container }}"` |
| `pulse_data_dir` | Persistent directory mounted to `/data` | `"{{ docker_base_mnt }}/{{ pulse_instance.container }}"` |

### Group Variables (`inventories/group_vars/docker_hosts.yml`)

- `pulse_instance`: `{ container: pulse-d02, domain: "pulse-d02.local.rwdevs.com", port: 7655 }`
- `shared_timezone`, `docker_base_dir`, `docker_base_mnt`

---

## Infisical Secrets

None.

---

## Dependencies

- `community.docker` collection

---

## Example

```yaml
- name: Deploy Pulse
  hosts: pulse
  become: true
  roles:
    - role: apps/pulse
    - role: docker/image_cleanup
```

---

## Make Targets

```bash
make pulse-check
make pulse
```

---

## Notes

- Publishes `{{ pulse_instance.port }}:7655`, sets `PULSE_DEPLOYMENT_METHOD=docker_compose`, runs `docker_compose_v2` with `pull: always`, asserts `{{ pulse_instance.container }}` reaches `running` state, configures `json-file` logging (`10m`, max `3`), and opts into Watchtower notifications.
