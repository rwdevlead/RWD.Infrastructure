# apps/traefik

Deploys Traefik reverse proxy via Docker Compose on `dev-docker-02`, terminating TLS with Cloudflare DNS-01 ACME certificates and routing both Docker-labeled containers and static `dynamic.yml` backends.

---

## Requirements

- Docker Engine and Compose v2 (`docker/engine`, `docker/compose`)
- External Docker network (`shared_docker_network`, default `traefik`)
- Infisical secrets populated under `/ansible/cloudflare`
- DNS records for `*.local.rwdevs.com` / `local.rwdevs.com` managed in Cloudflare and pointing to `dev-docker-02` (`192.168.50.16`)

---

## Variables

### Role Defaults (`defaults/main.yml`)

| Variable | Description | Default |
| :--- | :--- | :--- |
| `traefik_image` | Docker image repository | `"traefik"` |
| `traefik_tag` | Docker image tag | `"v3.6.1"` |
| `traefik_base_dir` | Host directory for `docker-compose.yml` | `"{{ docker_base_dir }}/{{ traefik_instance.name }}"` |
| `traefik_data_dir` | Host directory for config, ACME, volumes, and logs | `"{{ docker_base_mnt }}/{{ traefik_instance.name }}"` |
| `traefik_volumes_dir` | Volumes subdirectory | `"{{ traefik_data_dir }}/volumes"` |
| `traefik_logs_dir` | Logs subdirectory | `"{{ traefik_data_dir }}/logs"` |
| `traefik_acme_email` | ACME registration email | `"{{ secrets.ansible.cloudflare.ACME_EMAIL }}"` |
| `traefik_acme_resolver` | ACME certificate resolver name | `"cloudflare"` |
| `traefik_acme_domain_main` | Primary ACME certificate domain | `"rwdevs.com"` |
| `traefik_acme_domain_sans` | Comma-separated SANs | `"*.rwdevs.com,*.local.rwdevs.com"` |
| `traefik_acme_server` | Let's Encrypt ACME directory URL | `"https://acme-v02.api.letsencrypt.org/directory"` |
| `traefik_port_http` | HTTP entrypoint port | `80` |
| `traefik_port_https` | HTTPS entrypoint port | `443` |
| `traefik_port_api` | API/ping port | `8080` |
| `traefik_dns_resolvers` | DNS resolvers used for ACME DNS-01 checks | `["1.1.1.1:53", "1.0.0.1:53"]` |
| `traefik_insecure_skip_verify` | Skip TLS verification on proxied backends | `true` |
| `traefik_hsts_max_age` | HSTS max-age header value (seconds) | `15552000` |
| `traefik_ip_whitelist` | Allowed CIDRs for `default-whitelist` middleware | `["10.0.0.0/8", "{{ network.subnet }}", "172.18.0.0/16"]` |
| `cloudflare_dns_api_token` | Cloudflare API token (`CF_DNS_API_TOKEN`) | `"{{ secrets.ansible.cloudflare.CF_DNS_API_TOKEN }}"` |

### Group Variables (`inventories/group_vars/docker_hosts.yml`)

- `traefik_instance`: `{ name: "traefik-d02", domain: "traefik-d02.local.rwdevs.com", server: dev-docker-02, container: traefik-d02, url: "https://traefik-d02.local.rwdevs.com" }`
- `proxmox_instances`: List of Proxmox VE nodes routed dynamically in `dynamic.yml.j2`
- `shared_docker_network`, `shared_docker_api_version`, `docker_base_dir`, `docker_base_mnt`
- `vms` and `network.subnet` from `iac/shared/infrastructure.yml`

---

## Infisical Secrets (`/ansible/cloudflare`)

| Secret Key | Description |
| :--- | :--- |
| `CF_DNS_API_TOKEN` | Cloudflare API token with `Zone:DNS:Edit` permission for DNS-01 challenges |
| `ACME_EMAIL` | Let's Encrypt ACME registration and renewal notification email |

---

## Dependencies

- `infisical_secrets` (invoked by `playbooks/traefik.yml`)
- `community.docker` collection

---

## Example

```yaml
- name: Deploy Traefik
  hosts: dev-docker-02
  become: true
  vars:
    infisical_secret_paths:
      - "/ansible/cloudflare"
  roles:
    - infisical_secrets
    - apps/traefik
```

---

## Make Targets

```bash
make traefik-check
make traefik
```

---

## Notes

- **Entrypoints:** `web` (`:80`), `websecure` (`:443`, default with `cloudflare` resolver), and `smtp` (`:8025` for TCP routing). `--api.dashboard=true` and `--api.insecure=false` are set; the dashboard is served over HTTPS at `https://{{ traefik_instance.domain }}` (`api@internal`), while port `8080` serves `--ping` health checks.
- **Dynamic File Routes (`templates/dynamic.yml.j2`):** Routes the Traefik dashboard, `proxmox_instances`, `pihole-p01.local.rwdevs.com` (`prod-docker-01:8888`), `tm.local.rwdevs.com` (`dev-omv-01`), `uptime-kuma-p01.local.rwdevs.com` (`prod-docker-01:3001`), and `ha.local.rwdevs.com` (`homeassistant:8123`), and defines `https-redirectscheme`, `pihole-redirect`, `default-headers`, `default-whitelist`, and `secured` middlewares.
- **Health Checks:** Waits for container health status `healthy` (`traefik healthcheck --ping`) and verifies `http://localhost:8080/ping` returns HTTP `200`.
