# Ansible Configuration Management

This directory contains Ansible playbooks and roles for configuring and managing Docker-based infrastructure.

## Directory Structure

```
ansible/
├── playbooks/                 # Ansible playbooks
│   ├── site.yml              # Main site playbook (runs all roles)
│   ├── base.yml              # Base system configuration
│   ├── docker.yml            # Docker engine and daemon setup
│   ├── storage.yml           # NFS and storage configuration
│   ├── traefik.yml           # Traefik reverse proxy
│   ├── portainer.yml         # Portainer container management UI
│   └── apps/                 # Application-specific playbooks
│       └── homepage.yml      # Homepage application
├── inventories/              # Inventory files
│   ├── docker.yml            # Docker host inventory
│   └── apps/                 # Service inventories
│       ├── homepage.yml
│       ├── mailrise.yml
│       ├── portainer.yml
│       └── semaphore.yml
├── roles/                    # Reusable Ansible roles
│   ├── base/                 # Base system roles
│   │   ├── hostname/         # Hostname configuration
│   │   ├── security/         # Security hardening
│   │   ├── ssh/              # SSH configuration
│   │   └── users/            # User management
│   ├── docker/               # Docker-related roles
│   │   ├── compose/          # Docker Compose setup
│   │   └── engine/           # Docker engine installation
│   ├── storage/              # Storage roles
│   │   └── nfs/              # NFS client setup
│   └── apps/                 # Application roles
│       ├── traefik/          # Traefik reverse proxy
│       ├── homepage/         # Homepage dashboard
│       ├── portainer/        # Portainer UI
│       ├── mailrise/         # Mailrise email gateway
│       ├── pihole/           # Pi-hole DNS and ad-blocking
│       ├── semaphore/        # Semaphore task runner
│       └── docker/           # Docker ecosystem
├── vars/                     # Global variables
│   ├── global.yml            # Global configuration
│   └── secrets.yml           # Encrypted secrets (vault)
├── collections/              # Ansible collections
│   └── requirements.yml      # Required collections
├── ansible.cfg               # Ansible configuration
└── README.md                 # This file
```

## Quick Start

### Running Playbooks

Run all plays for a host:

```bash
ansible-playbook playbooks/site.yml -i inventories/docker.yml
```

Run specific playbook:

```bash
ansible-playbook playbooks/traefik.yml -i inventories/docker.yml
```

### Configuration

- **Inventory**: Edit `inventories/docker.yml` to define target hosts
- **Global vars**: Edit `vars/global.yml` for shared configuration
- **Secrets**: Use `ansible-vault` for sensitive data in `vars/secrets.yml`

## Key Services

### Traefik Reverse Proxy

**Dashboard**: `http://proxy1.local.rwdevs.com:8080/dashboard`

Traefik handles:

- HTTP/HTTPS routing on ports 80/443
- Automatic certificate generation via Let's Encrypt + Cloudflare DNS-01
- Service discovery via Docker labels
- Middleware for security headers and IP allowlisting

See [Traefik Role Documentation](roles/apps/traefik/README.md) for details.

### Portainer

Container management UI accessible via Traefik routing.

### Pi-hole

DNS and ad-blocking service for local network.

### Homepage

Custom dashboard application.

## Variables & Configuration

### Global Variables (`vars/global.yml`)

Core configuration affecting all hosts and services:

- Domain names
- Network settings
- Service ports and endpoints

### Secrets (`vars/secrets.yml`)

Sensitive data managed via Ansible Vault:

- API tokens
- Passwords
- Certificate credentials

**Encrypt/Edit secrets**:

```bash
ansible-vault edit vars/secrets.yml
ansible-vault view vars/secrets.yml  # View only
```

### Role Variables

Each role has `defaults/main.yml` defining customizable variables. Override in:

- Playbooks
- Inventory files
- Group/host variable files

## Collections

Required collections are listed in `collections/requirements.yml`:

```bash
ansible-galaxy collection install -r collections/requirements.yml
```

Key collections:

- `community.docker` - Docker module support
- `community.general` - General modules

## Running from Terraform

The Terraform configuration can trigger these playbooks via `local-exec` provisioners:

```bash
make apply  # Runs Terraform + Ansible
```

## Troubleshooting

### Playbook Errors

```bash
# Run in check mode (dry-run)
ansible-playbook playbooks/traefik.yml -i inventories/docker.yml --check

# Verbose output
ansible-playbook playbooks/traefik.yml -i inventories/docker.yml -vvv
```

### SSH Issues

```bash
# Test SSH connectivity
ansible all -i inventories/docker.yml -m ping

# Debug SSH connection
ansible docker-vm01 -i inventories/docker.yml -m debug -a "msg=test" -vvv
```

### Vault Issues

```bash
# If vault password is cached, clear it
unset ANSIBLE_VAULT_PASSWORD_FILE
```

## Best Practices

1. **Use roles for reusability** - Don't create monolithic playbooks
2. **Define variables in defaults** - Make roles configurable
3. **Use vault for secrets** - Never commit passwords or tokens
4. **Test in check mode** - Run `--check` before applying changes
5. **Document role behavior** - Update README.md in role directories
6. **Use handlers for restarts** - Minimize service disruptions
7. **Idempotent operations** - Playbooks should be safely re-runnable

## Resources

- [Ansible Documentation](https://docs.ansible.com/)
- [Community Collections](https://galaxy.ansible.com/collections/browse)
- [Traefik Role](roles/apps/traefik/README.md)
- [Base Role Documentation](roles/base/README.md)
