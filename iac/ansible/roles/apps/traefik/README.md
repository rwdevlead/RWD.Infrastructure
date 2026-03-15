# apps/traefik

Deploys Traefik v3.6.1 reverse proxy on a Docker host using Docker Compose.

## Overview

Traefik is configured as a reverse proxy with:
- **HTTP/HTTPS routing** on ports 80/443 with automatic certificate generation
- **Insecure API dashboard** on port 8080 for monitoring and management
- **Docker provider** for automatic service discovery via labels
- **File provider** for dynamic configuration via `dynamic.yml`
- **DNS-01 ACME validation** via Cloudflare for wildcard certificates

## Responsibilities

- Create persistent directories for configuration and ACME certs
- Render `docker-compose.yml` and dynamic configuration (`dynamic.yml`)
- Deploy Traefik via Docker Compose
- Ensure Docker network exists (`traefik`)

## Prerequisites

- Docker installed on host
- External Docker network named `traefik`
- Cloudflare API token for DNS-01 ACME challenges
- DNS entries pointing hostnames to the Docker host IP

## Variables

| Variable                 | Description                                          | Default                |
| ------------------------ | ---------------------------------------------------- | ---------------------- |
| traefik_image            | Docker image name                                    | `traefik`              |
| traefik_tag              | Docker image tag                                     | `v3.6.1`               |
| traefik_base_dir         | Host path for docker-compose.yml                     | `/opt/traefik`         |
| traefik_data_dir         | Host path for config and ACME storage                | `/mnt/docker/traefik`  |
| traefik_network          | Docker network name for Traefik                      | `traefik`              |
| traefik_dashboard_domain | Hostname for Traefik dashboard                       | `proxy.local.rwdevs.com` |
| traefik_acme_email       | Email for ACME certificate registration             | `srdevlead@outlook.com` |
| traefik_acme_resolver    | ACME resolver name (Cloudflare)                      | `cloudflare`           |
| cloudflare_dns_api_token | Cloudflare API token for DNS-01 challenges          | From env var           |

## Configuration

### Entrypoints

- **web (port 80)**: HTTP entry point for traffic and ACME HTTP challenges
- **websecure (port 443)**: HTTPS entry point with automatic TLS via ACME
- **API (port 8080)**: Insecure API endpoint for dashboard access

### Certificate Management

- Wildcard certificate for `*.local.rwdevs.com` via Let's Encrypt
- DNS-01 validation through Cloudflare
- Certificates stored in `/mnt/docker/traefik/acme/acme.json`

### Middleware

Three middlewares are defined in `dynamic.yml`:
- `default-headers`: Security headers (HSTS, Frame-deny, etc.)
- `default-whitelist`: IP allowlist for private ranges (10.0.0.0/8, 192.168.0.0/16, 172.16.0.0/12, 127.0.0.1)
- `secured`: Chain combining whitelist + headers

### Service Discovery

Services can be routed via:
1. **Docker labels** (preferred) - auto-discovered from containers on `traefik` network
2. **File provider** - static routes defined in `dynamic.yml`

## Dashboard Access

**URL**: `http://proxy1.local.rwdevs.com:8080/dashboard` (or substitute actual hostname/IP)

The dashboard provides:
- Traffic overview and routing rules
- Services, routers, and middleware status
- Real-time metrics and performance data

Note: The dashboard runs on the insecure API port (8080) by design - `api@internal` service cannot be exposed through standard routing.

## Service Routing Example

### Docker Labels (Recommended)

```yaml
labels:
  - traefik.enable=true
  - traefik.http.routers.myapp.rule=Host(`myapp.local.rwdevs.com`)
  - traefik.http.routers.myapp.entrypoints=websecure
  - traefik.http.services.myapp.loadbalancer.server.port=3000
```

### File Provider

Services can also be defined in `dynamic.yml`:
```yaml
http:
  routers:
    myservice:
      entryPoints:
        - websecure
      rule: "Host(`myservice.local.rwdevs.com`)"
      service: myservice
      tls: {}
  services:
    myservice:
      loadBalancer:
        servers:
          - url: "http://app-container:3000"
```

## Security Considerations

- The API port (8080) is insecure - only expose in trusted networks
- Middleware `default-whitelist` restricts access to private IP ranges by default
- Use `secured` middleware on services that need IP filtering
- Certificates are automatically renewed by Let's Encrypt
- Never commit acme.json or certificate files to version control

## Files

- `docker-compose.yml.j2`: Main Traefik container definition with all command-line config
- `dynamic.yml.j2`: Dynamic routes, services, and middleware definitions
- Unused: `traefik.yml.j2` (kept for reference, using command-line args instead)

## Troubleshooting

- **404 errors on routes**: Verify service labels/definitions and that container is on `traefik` network
- **Certificate generation delays**: Check Cloudflare API token and DNS propagation
- **Dashboard not loading**: Ensure port 8080 is accessible and open
- **Routing loops**: Check for conflicting rules with `Host()` and `PathPrefix()` conditions
