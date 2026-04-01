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
- Cloudflare API token for DNS-01 ACME challenges (see [Certificate Management](#certificate-management))
- DNS entries pointing hostnames to the Docker host IP

## Variables

| Variable                 | Description                                          | Default                |
| ------------------------ | ---------------------------------------------------- | ---------------------- |
| traefik_image            | Docker image name                                    | `traefik`              |
| traefik_tag              | Docker image tag                                     | `v3.6.1`               |
| traefik_base_dir         | Host path for docker-compose.yml                     | `/opt/traefik`         |
| traefik_data_dir         | Host path for config and ACME storage                | `/mnt/docker/traefik`  |
| traefik_volumes_dir      | Host path for persistent data/custom files           | `/mnt/docker/traefik/volumes` |
| traefik_logs_dir         | Host path for Traefik logs                           | `/mnt/docker/traefik/logs` |
| traefik_network          | Docker network name for Traefik                      | `traefik`              |
| traefik_dashboard_domain | Hostname for Traefik dashboard                       | `proxy.local.rwdevs.com` |
| traefik_acme_email       | Email for ACME certificate registration             | `srdevlead@outlook.com` |
| traefik_acme_resolver    | ACME resolver name (Cloudflare)                      | `cloudflare`           |
| cloudflare_dns_api_token | Cloudflare API token for DNS-01 challenges          | From env var `CF_DNS_API_TOKEN` |

## Certificate Management

### ACME & Let's Encrypt Configuration

Traefik automatically requests and manages SSL/TLS certificates from Let's Encrypt using DNS-01 validation via Cloudflare.

**Certificate Details:**
- **Domain**: `local.rwdevs.com` (main)
- **Wildcard**: `*.local.rwdevs.com` (all subdomains)
- **Validation Method**: DNS-01 (Cloudflare)
- **Storage**: `/mnt/docker/traefik/acme/acme.json` (NFS mounted, persistent)
- **Renewal**: Automatic (Let's Encrypt renews before expiry)
- **Email**: Used only for certificate registration and renewal notices

### Cloudflare API Token Setup

**Required Permissions:**
- Zone:DNS:Edit (for DNS-01 challenges)

**How to Create Token:**
1. Go to [Cloudflare Dashboard](https://dash.cloudflare.com/profile/api-tokens)
2. Click "Create Token"
3. Use template: "Edit zone DNS"
4. Select your zone: `local.rwdevs.com` (or parent domain)
5. Click "Continue to summary" → "Create Token"
6. Copy the token to `.env` file:
   ```bash
   CF_DNS_API_TOKEN="your_token_here"
   ```

**Verification:**
```bash
# Before deployment, test token validity
curl -X GET "https://api.cloudflare.com/client/v4/user/tokens/verify" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### DNS Requirements

Before deploying Traefik:
1. **Add DNS A records** pointing to your Docker host:
   ```
   local.rwdevs.com     A   192.168.50.12
   *.local.rwdevs.com   A   192.168.50.12
   ```
2. **Verify DNS propagation:**
   ```bash
   nslookup local.rwdevs.com
   nslookup test.local.rwdevs.com
   ```
3. **Ensure DNS is managed by Cloudflare** (required for DNS-01 challenges)

### Certificate Renewal

- **Automatic**: Let's Encrypt renews certificates automatically 30 days before expiry
- **Renewal logs**: Check Traefik logs in `/mnt/docker/traefik/logs/`
- **Renewal failures**: Usually due to Cloudflare token issues or DNS misconfiguration
  ```bash
  # View renewal status in acme.json
  cat /mnt/docker/traefik/acme/acme.json | jq '.[] | select(.renewBefore != null)'
  ```

### First Deployment & Certificate Generation

**Timeline:**
1. Traefik starts and validates Cloudflare token
2. Requests wildcard certificate from Let's Encrypt (can take 30-60 seconds)
3. Let's Encrypt challenges DNS record via Cloudflare API
4. Cloudflare propagates DNS change
5. Let's Encrypt validates challenge
6. Certificate issued and stored in `acme.json`

**Monitoring First Cert:**
```bash
# Watch Traefik logs during first certificate request
docker logs -f traefik

# Check if certificate exists (after 2-3 minutes)
ls -la /mnt/docker/traefik/acme/acme.json
```

### Troubleshooting Certificate Issues

| Problem | Cause | Solution |
|---------|-------|----------|
| No certificate issued after 5 min | Invalid Cloudflare token | Check `CF_DNS_API_TOKEN` in `.env` |
| API not accessible | DNS not resolved | Verify DNS A records are set |
| Token validation fails | Token expired/revoked | Create new token in Cloudflare dashboard |
| Mixed content warnings | HTTP services on HTTPS | Configure backends correctly or use TLS upstream |
| Certificate mismatch | Wrong domain in config | Verify `local.rwdevs.com` in docker-compose config |

## Configuration

### Entrypoints

- **web (port 80)**: HTTP entry point for traffic and ACME HTTP challenges
- **websecure (port 443)**: HTTPS entry point with automatic TLS via ACME
- **API (port 8080)**: Insecure API endpoint for dashboard access

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
