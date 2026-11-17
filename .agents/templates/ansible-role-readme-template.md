# <category>/<role_name>

<One-sentence summary of what the role configures/deploys, target inventory group, and mechanism (e.g., Docker Compose, systemd, APT).>

---

## Requirements

- <Prerequisite 1 (e.g., Docker Engine and Compose v2 via `docker/engine` and `docker/compose`)>
- <Prerequisite 2 (e.g., External `traefik` network / NFS mount / Infisical path populated)>

---

## Variables

### Role Defaults (`defaults/main.yml`)

| Variable | Description | Default |
| :--- | :--- | :--- |
| `<role>_image` | Docker image repository | `"<image>"` |
| `<role>_tag` | Docker image tag | `"latest"` |
| `<role>_base_dir` | Host directory for Compose file | `"{{ docker_base_dir }}/<name>"` |

### Group Variables (`inventories/group_vars/<group>.yml`)

- `<group_var>`: <Describe host/service metadata keys consumed from `group_vars` or `iac/shared/infrastructure.yml`.>

---

## Infisical Secrets (`<path>` or `None`)

| Secret Key | Description |
| :--- | :--- |
| `<SECRET_KEY>` | <Purpose and where it is injected> |

---

## Dependencies

- `infisical_secrets` *(if Infisical secrets are required)*
- `community.docker` collection *(if using Docker modules)*

---

## Example

```yaml
- name: Deploy <Service>
  hosts: <inventory_group>
  become: true
  vars:
    infisical_secret_paths:
      - "<path>"
  roles:
    - infisical_secrets
    - <category>/<role_name>
```

---

## Make Targets

```bash
make <target>-check
make <target>
```

---

## Notes

- <Ports, Traefik routing, Watchtower labels, check-mode behavior, health assertions, or operational caveats.>
