# apps/watchtower

Deploys Watchtower across `docker_hosts` in notify-only (`--monitor-only`), label-opt-in (`--label-enable`) mode, emailing available container image updates via Mailrise and exposing an authenticated HTTP metrics endpoint.

---

## Requirements

- Docker Engine (`docker/engine`)
- Mailrise SMTP relay reachable at `{{ mailrise.domain }}:{{ mailrise.port }}` (`apps/mailrise`)
- Infisical secrets populated under `/ansible/watchtower`

---

## Variables

### Role Defaults (`defaults/main.yml`)

| Variable | Description | Default |
| :--- | :--- | :--- |
| `watchtower_image` | Watchtower Docker image | `containrrr/watchtower` |
| `watchtower_schedule` | 6-field cron schedule (with seconds) | `"0 0 4 * * *"` *(04:00 daily)* |
| `watchtower_monitor_only` | Notify only without auto-updating containers | `true` |
| `watchtower_cleanup` | Remove old images (`--cleanup`) if updating | `true` |

### Group Variables (`inventories/group_vars/docker_hosts.yml`)

- `watchtower_instances[inventory_hostname]`: Defines container `name` and sender `email` (`watchtower-d02@rwdevs.com`, `watchtower-p01@rwdevs.com`).
- `mailrise`: Target SMTP server (`mailrise.domain`, `mailrise.port`, `mailrise.email`).
- `shared_timezone`, `shared_docker_api_version`, `shared_docker_network`.

---

## Infisical Secrets (`/ansible/watchtower`)

| Secret Key | Description |
| :--- | :--- |
| `API_TOKEN` | Bearer token securing `WATCHTOWER_HTTP_API_METRICS` on port `8082:8080` |

---

## Dependencies

- `infisical_secrets` (invoked by `playbooks/watchtower.yml`)
- `community.docker` collection

---

## Example

```yaml
- name: Deploy Lab Package Monitor
  hosts: docker_hosts
  become: true
  vars:
    infisical_secret_paths:
      - "/ansible/watchtower"
  roles:
    - infisical_secrets
    - apps/watchtower
```

---

## Make Targets

```bash
make watchtower-check
make watchtower
```

---

## Notes

- Watchtower sets `com.centurylinklabs.watchtower.enable: "false"` on itself and only monitors containers labeled `com.centurylinklabs.watchtower.enable=true`.
- Exposes HTTP metrics on host port `8082` (`8082:8080`).
