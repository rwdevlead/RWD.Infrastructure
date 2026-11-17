# Application Roles (`apps/`)

Roles under `iac/ansible/roles/apps/` deploy containerized services onto `docker_hosts` (`dev-docker-02` and `prod-docker-01`) attached to the shared external `traefik` Docker bridge network.

---

## Application Role Index

| Role | Target Host(s) | Infisical Path(s) | Make Targets | Docs |
| :--- | :--- | :--- | :--- | :--- |
| `apps/traefik` | `dev-docker-02` | `/ansible/cloudflare` | `make traefik-check` / `make traefik` | [README](traefik/README.md) |
| `apps/pihole` | `docker_hosts` | `/ansible/pihole` | `make pihole-check` / `make pihole` | [README](pihole/README.md) |
| `apps/nebula-sync` | `prod-docker-01` | `/ansible/pihole`, `/ansible/uptime_kuma` | `make nebula-check` / `make nebula` | [README](nebula-sync/README.md) |
| `apps/mailrise` | `prod-docker-01` | `/ansible/mail`, `/ansible/mailrise` | `make mailrise-check` / `make mailrise` | [README](mailrise/README.md) |
| `apps/portainer` | `dev-docker-02` | `/ansible/portainer` | `make portainer-check` / `make portainer` | [README](portainer/README.md) |
| `apps/portainer_agent` | `portainer_agents` (`prod-docker-01`) | `/ansible/portainer` | `make portainer-agent-check` / `make portainer-agent` | [README](portainer_agent/README.md) |
| `apps/homarr` | `homarr` (`dev-docker-02`) | `/ansible/homarr` | `make homarr-check` / `make homarr` | [README](homarr/README.md) |
| `apps/uptime_kuma` | `uptime_kuma` (`prod-docker-01`) | — | `make uptime-kuma-check` / `make uptime-kuma` | [README](uptime_kuma/README.md) |
| `apps/pulse` | `pulse` (`dev-docker-02`) | — | `make pulse-check` / `make pulse` | [README](pulse/README.md) |
| `apps/watchtower` | `docker_hosts` | `/ansible/watchtower` | `make watchtower-check` / `make watchtower` | [README](watchtower/README.md) |

---

## Common Patterns

- **Instance Metadata:** Domains, container names, and ports are configured in [inventories/group_vars/docker_hosts.yml](../../inventories/group_vars/docker_hosts.yml) and [iac/shared/infrastructure.yml](../../../shared/infrastructure.yml).
- **Secrets:** Playbooks that need credentials run `infisical_secrets` before the application role so templates/tasks can read `secrets.ansible.<path>.<KEY>`.
- **Updates:** Services opt in to Watchtower update notifications via the `com.centurylinklabs.watchtower.enable=true` Docker label.
