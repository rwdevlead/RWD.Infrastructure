# docker/portainer

Deploys Portainer CE using Docker Compose.

## Responsibilities

- Create persistent directories
- Render docker-compose.yml
- Deploy and update Portainer

## Variables

| Variable             | Description       |
| -------------------- | ----------------- |
| portainer_base_dir   | Install directory |
| portainer_http_port  | HTTP port         |
| portainer_https_port | HTTPS port        |
| portainer_update     | Pull latest image |

## Notes

- No firewall rules applied
- Designed as a template for app roles

## Networking

- Exposed via Traefik (when deployed)
- No host ports published
- Docker network: `traefik`

## Access

- URL: https://portainer.local.rwdevs.com
- Requires Traefik to be running
