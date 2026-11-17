# infisical_secrets

Logs into Infisical using Universal Auth, reads configured secret paths via the `infisical.vault` collection, and merges them into a single `secrets` fact for downstream roles.

---

## Requirements

- `infisical.vault` Ansible collection (`iac/ansible/collections/requirements.yml`)
- Environment variables loaded (typically via root `.env` and `Makefile`):
  - `INFISICAL_CLIENT_ID`
  - `INFISICAL_CLIENT_SECRET`
  - `INFISICAL_PROJECT_ID`

---

## Variables

| Variable | Description | Default |
| :--- | :--- | :--- |
| `infisical_secret_paths` | List of Infisical paths to read and merge | `['/']` (fallback in `tasks/main.yaml`; `defaults/main.yml` is commented out) |
| `infisical_env_slug` | Infisical environment slug to query | `'dev'` |

---

## Secrets Structure

`files/merge_infisical_secrets.py` merges all retrieved paths (last-merge-wins via recursive combine) into the `secrets` fact with three access patterns:

- **Nested path map:** `secrets.ansible.mail.OUTLOOK_MAIL_USER`
- **Dotted-key bracket access:** `secrets['ansible.mail']['OUTLOOK_MAIL_USER']`
- **Promoted root keys (`/`):** `secrets.SECRET`

---

## Example

```yaml
- name: Deploy Mailrise Alerts
  hosts: prod-docker-01
  become: true
  vars:
    infisical_secret_paths:
      - "/ansible/mail"
      - "/ansible/mailrise"
  roles:
    - infisical_secrets
    - apps/mailrise
```

Accessing a secret in a downstream task or template:

```yaml
username: "{{ secrets.ansible.mail.OUTLOOK_MAIL_USER }}"
```

---

## Make Targets

```bash
# Run local Infisical integration assertions (playbooks/test_infisical.yml)
make test-infisical
```

---

## Notes

- Login and secret reads run with `delegate_to: localhost`, `run_once: true`, `become: false`, and `check_mode: false` so secrets remain available during `--check` dry-runs.
- Do not vendor `infisical.vault` into the repository; install it with `ansible-galaxy collection install -r iac/ansible/collections/requirements.yml`.
