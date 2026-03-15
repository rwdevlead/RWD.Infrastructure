# apps/semaphore

Deploys Ansible Semaphore using Docker Compose.

## Responsibilities

- Deploy Semaphore + Postgres
- Persist application and DB data
- Support Traefik or direct port access

## Ports

- 3000 (internal)
- 3001 (host, if Traefik disabled)

## Notes

- Secrets should be stored in Ansible Vault
- Semaphore will manage this Ansible repo
