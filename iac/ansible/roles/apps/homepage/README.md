# apps/homepage

Deploys Homepage using Docker Compose.

## Responsibilities

- Create config directory
- Render docker-compose.yml
- Deploy and update Homepage

## Variables

| Variable        | Description       |
| --------------- | ----------------- |
| homepage_port   | Port exposed      |
| homepage_update | Pull latest image |

## Notes

- Traefik integration can be added later
- Pattern used for all app roles
