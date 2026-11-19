# apps/mailrise

Deploys the Mailrise SMTP-to-Apprise relay container via Docker Compose on `prod-docker-01`, forwarding local infrastructure alert emails through iCloud and Outlook SMTP relays.

---

## Requirements

- Docker Engine and Compose v2 (`docker/engine`, `docker/compose`)
- Infisical secrets populated under `/ansible/mail` and `/ansible/mailrise`

---

## Variables

### Role Defaults (`defaults/main.yml`)

| Variable | Description | Default |
| :--- | :--- | :--- |
| `mailrise_image` | Docker image repository | `"yoryan/mailrise"` |
| `mailrise_tag` | Docker image tag | `"1.4.0"` |
| `mailrise_base_dir` | Host directory for `docker-compose.yml` | `"/opt/mailrise"` |
| `mailrise_data_dir` | Host directory for `config/mailrise.conf` | `"/mnt/docker/mailrise"` |
| `mailrise_icloud_user` | iCloud SMTP username | `"{{ secrets.ansible.mail.ICLOUD_MAIL_USER }}"` |
| `mailrise_icloud_pass` | iCloud SMTP app password | `"{{ secrets.ansible.mail.ICLOUD_MAIL_PASS }}"` |
| `mailrise_icloud_from` | iCloud sender address | `"{{ secrets.ansible.mail.ICLOUD_MAIL_FROM }}"` |
| `mailrise_outlook_user` | Outlook SMTP username | `"{{ secrets.ansible.mail.OUTLOOK_MAIL_USER }}"` |
| `mailrise_outlook_pass` | Outlook SMTP password | `"{{ secrets.ansible.mail.OUTLOOK_MAIL_PASS }}"` |
| `mailrise_outlook_from` | Outlook sender address | `"{{ secrets.ansible.mail.OUTLOOK_MAIL_FROM }}"` |
| `mailrise_target_email` | Destination alert email address | `"{{ secrets.ansible.mailrise.EMAIL_DEST }}"` |

### Group Variables (`inventories/group_vars/docker_hosts.yml`)

- `mailrise`: `{ name: mailrise-p01, domain: "mailrise.local.rwdevs.com", email: "email@mailrise.xyz", port: 8025 }`
- `shared_docker_network`: `"traefik"`

---

## Infisical Secrets

| Path | Secret Keys |
| :--- | :--- |
| `/ansible/mail` | `ICLOUD_MAIL_USER`, `ICLOUD_MAIL_PASS`, `ICLOUD_MAIL_FROM`, `OUTLOOK_MAIL_USER`, `OUTLOOK_MAIL_PASS`, `OUTLOOK_MAIL_FROM` |
| `/ansible/mailrise` | `EMAIL_DEST` |

---

## Dependencies

- `infisical_secrets` (invoked by `playbooks/mailrise.yml`)
- `community.docker` collection

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

---

## Make Targets

```bash
make mailrise-check
make mailrise
```

---

## Notes

- Exposes SMTP on `8025:8025` (plus `8081:8080`) and configures a Traefik TCP router on entrypoint `smtp` (`HostSNI(*)`).
- Defines `email`, `icloud`, and `outlook` Mailrise routes in `config/mailrise.conf` (`mode: "0600"`, `diff: false` so SMTP credentials are not printed during `--check --diff`).
- Note: `tasks/main.yml` renders `mailrise.conf` and `docker-compose.yml` with `check_mode: no` even during `--check`.

### Manual SMTP Test (`swaks`)

```bash
swaks --to email@mailrise.xyz --server 192.168.50.14 --port 8025
# or
swaks --to email@mailrise.xyz --server mailrise.local.rwdevs.com --port 8025
```
