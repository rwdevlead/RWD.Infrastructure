# apps/traefik

Deploys Traefik reverse proxy with Let's Encrypt.

## Responsibilities

- HTTPS termination
- Docker-based routing
- Shared proxy network

## Networks

- proxy (public)
- internal (private)

## Usage

Other apps must:

- Join the proxy network
- Define Traefik labels
