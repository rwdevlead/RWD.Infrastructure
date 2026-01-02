# apps/mailrise

Deploys MailRise SMTP alert router.

## Responsibilities

- Render MailRise config
- Deploy container via Docker Compose

## Ports

- SMTP: configurable (default 8025)

## Notes

- No web UI
- Credentials should be stored in Ansible Vault
