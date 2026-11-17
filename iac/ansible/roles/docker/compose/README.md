# docker/compose

Ensures the Docker Compose v2 plugin is installed, verifies `docker compose version`, and creates the shared external `traefik` Docker bridge network.

---

## Requirements

- Docker Engine installed (`docker/engine`)

---

## Variables

| Variable | Description | Default |
| :--- | :--- | :--- |
| `docker_compose_package` | Package name for Docker Compose v2 plugin | `docker-compose-plugin` |

---

## Infisical Secrets

None.

---

## Dependencies

- `community.docker` collection (for `community.docker.docker_network`)
- `docker/engine`

---

## Example

```yaml
- hosts: docker_hosts
  become: true
  roles:
    - docker/compose
```

---

## Make Targets

```bash
make docker-check
make docker
```

---

## Notes

- Uses Docker's native v2 CLI (`docker compose`) rather than legacy standalone `docker-compose`.
- Creates the `traefik` bridge network directly in `tasks/main.yml`.
