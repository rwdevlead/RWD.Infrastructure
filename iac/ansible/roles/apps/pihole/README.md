# apps/pihole

Deploys Pi-hole DNS server using Docker Compose.

## Responsibilities

- DNS ad blocking
- Admin web UI
- Persistent configuration

## Ports

- 53 TCP/UDP (DNS)
- 80 (internal)
- Optional Traefik UI exposure

## Warnings

- Do NOT run multiple Pi-hole instances on the same host
- Do NOT proxy DNS through Traefik
