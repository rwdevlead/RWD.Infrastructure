# Ansible Configuration Management

This directory contains Ansible playbooks and roles for provisioning and configuring a Docker-based home lab infrastructure. The Ansible configuration automates system setup, docker deployment, and application configuration across multiple hosts.

## Overview

Ansible is used to:
- Configure base system settings (hostname, users, SSH, security)
- Install and configure Docker engine and Docker Compose
- Deploy containerized applications and services
- Manage persistent storage (NFS mounts)
- Configure reverse proxy and DNS services
- Automate infrastructure management tasks

## Directory Structure

```
ansible/
├── playbooks/                 # Entry point playbooks
│   ├── base.yml              # Base system setup (hostname, users, SSH, security)
│   ├── docker.yml            # Docker engine and Docker Compose installation
│   ├── storage.yml           # NFS client and storage setup
│   ├── system_updates.yml    # OS package updates
│   ├── traefik.yml           # Traefik reverse proxy deployment
│   ├── portainer.yml         # Portainer container management UI
│   ├── pihole.yml            # Pi-hole DNS and ad-blocking
│   ├── homepage.yml          # Homepage dashboard
│   ├── mailrise.yml          # MailRise SMTP router
│   ├── watchtower.yml        # Watchtower automatic container updates
│   └── docker.yml            # Docker Compose stack setup
├── inventories/              # Host inventory definitions
│   ├── docker.yml            # Primary inventory for Docker hosts
│   ├── ubuntu.yml            # Ubuntu system inventory
│   └── apps/                 # Application-specific inventories
│       ├── homepage.yml
│       ├── mailrise.yml
│       ├── pihole.yml
│       ├── portainer.yml
│       └── watchtower.yml
├── roles/                    # Reusable roles organized by function
│   ├── base/                 # System configuration roles
│   │   ├── hostname/         # Set system hostname
│   │   ├── security/         # Hardening and security policies
│   │   ├── ssh/              # SSH daemon configuration
│   │   └── users/            # User account creation and management
│   ├── docker/               # Docker infrastructure roles
│   │   ├── compose/          # Docker Compose installation and setup
│   │   └── engine/           # Docker CE installation and configuration
│   ├── storage/              # Storage and volume management
│   │   └── nfs/              # NFS client mounting
│   └── apps/                 # Application-specific deployment roles
│       ├── traefik/          # Traefik reverse proxy
│       ├── portainer/        # Portainer container management
│       ├── homepage/         # Homepage dashboard
│       ├── pihole/           # Pi-hole DNS filtering
│       ├── mailrise/         # MailRise SMTP gateway
│       ├── watchtower/       # Automatic container updates
│       └── semaphore/        # Ansible Semaphore task scheduler
├── vars/                     # Variable definitions
│   ├── global.yml            # Global configuration variables
│   └── secrets.yml           # Vault-encrypted secrets (API keys, passwords)
├── collections/              # Ansible Galaxy collections
│   └── requirements.yml      # Required collection dependencies
├── ansible.cfg               # Ansible global configuration
└── README.md                 # This file
```

## Quick Start

### Prerequisites

```bash
# Install Ansible (macOS)
brew install ansible

# Install required collections
ansible-galaxy collection install -r iac/ansible/collections/requirements.yml
```

### Running Playbooks

Run all base configuration for a host:

```bash
ansible-playbook iac/ansible/playbooks/base.yml -i iac/ansible/inventories/docker.yml
```

Deploy Docker and a specific application:

```bash
ansible-playbook iac/ansible/playbooks/docker.yml -i iac/ansible/inventories/docker.yml
ansible-playbook iac/ansible/playbooks/traefik.yml -i iac/ansible/inventories/docker.yml
```

Run a specific playbook in check mode (dry-run):

```bash
ansible-playbook iac/ansible/playbooks/portainer.yml -i iac/ansible/inventories/docker.yml --check
```

### Configuration Files

- **Inventory**: `inventories/docker.yml` - Defines target hosts and groups
- **Global Variables**: `vars/global.yml` - Domain names, ports, network settings
- **Secrets**: `vars/secrets.yml` - API tokens, passwords (encrypted with Ansible Vault)

## System Configuration (Base Roles)

The `base.yml` playbook applies fundamental system configuration via the following roles:

### hostname
- Sets the system hostname and updates `/etc/hosts`
- Configures domain name resolutions
- Ensures hostname persistence across reboots

### users
- Creates unprivileged user accounts
- Configures SSH key-based authentication
- Sets up sudo access for administrative tasks
- Manages group memberships

### ssh
- Hardens SSH daemon configuration (`/etc/ssh/sshd_config`)
- Disables password authentication (key-only)
- Disables root login
- Configures listening ports
- Manages SSH banner and logging

### security
- Applies system hardening policies
- Configures firewall rules (UFW)
- Sets up fail2ban for intrusion prevention
- Applies kernel parameter tuning
- Manages SELinux/AppArmor policies

## Docker Infrastructure

The `docker.yml` playbook sets up Docker and related infrastructure:

### docker/engine
- Installs Docker Community Edition from official repository
- Configures Docker daemon (`/etc/docker/daemon.json`)
- Enables Docker service for automatic startup
- Adds users to docker group for permission management
- Configures log rotation and limits

### docker/compose
- Installs Docker Compose (latest version)
- Creates standard directories for docker-compose files
- Sets up docker networks for application communication

## Storage Configuration

The `storage.yml` playbook manages persistent storage:

### storage/nfs
- Mounts NFS shares from a central NFS server
- Creates mount points in `/mnt/docker` for application data
- Configures persistent mounting via `/etc/fstab`
- Sets up automatic mounting at system boot

## Deployed Applications

### Traefik Reverse Proxy

**Role**: `apps/traefik` | **Playbook**: `traefik.yml`

**Purpose**: Industry-standard reverse proxy and load balancer for routing traffic to containerized services.

**Key Features**:
- HTTP/HTTPS traffic routing on ports 80/443
- Automatic SSL/TLS certificate generation via Let's Encrypt
- DNS-01 ACME validation through Cloudflare for wildcard certificates
- Automatic service discovery from Docker labels
- Dynamic configuration via provider file
- Built-in dashboard (port 8080) for monitoring and management
- Middleware support for security headers, compression, authentication

**Configuration**:
- Deployed via Docker Compose in `/opt/traefik`
- Persistent data in `/mnt/docker/traefik` (ACME certificates, config)
- External Docker network: `traefik`
- Dashboard accessible at `https://proxy.local.rwdevs.com`

**Use Case**: Provides unified entry point for all services, handles SSL termination, simplifies access management.

---

### Portainer

**Role**: `apps/portainer` | **Playbook**: `portainer.yml`

**Purpose**: Web-based Docker container management and orchestration interface.

**Key Features**:
- Visual container and image management
- Deployment of applications from templates
- Volume and network management
- User authentication and RBAC
- Container logs and stats monitoring
- Registry management integration
- Stack (docker-compose) deployment

**Configuration**:
- Deployed via Docker Compose in `/opt/portainer`
- Persistent data in `/mnt/docker/portainer`
- Accessible via Traefik at `https://portainer.local.rwdevs.com`
- Supports both standalone and Docker Swarm modes

**Use Case**: Provides a user-friendly GUI for managing Docker containers without command-line access.

---

### Pi-hole

**Role**: `apps/pihole` | **Playbook**: `pihole.yml`

**Purpose**: Network-wide ad blocker and DNS server for local network filtering.

**Key Features**:
- DNS-level ad and malware blocking
- Gravity database with multiple blocklists
- Web-based admin dashboard
- Query logging and statistics
- DHCP server functionality
- DNS query caching
- Regular expression filtering

**Configuration**:
- Deployed via Docker Compose
- DNS listens on UDP/TCP port 53
- Admin dashboard on port 80 (internal)
- Persistent configuration in `/mnt/docker/pihole`
- Network interface binding for local network access

**Important Notes**:
- Do NOT run multiple Pi-hole instances on the same network
- Do NOT proxy DNS traffic through Traefik (defeats filtering purpose)
- Should be set as primary DNS for network devices

**Use Case**: Blocks ads and tracking domains at the network level before they reach client devices.

---

### Homepage

**Role**: `apps/homepage` | **Playbook**: `homepage.yml`

**Purpose**: Customizable dashboard application for quick access to all services.

**Key Features**:
- Web-based dashboard and service aggregator
- Service status monitoring
- Quick links to applications
- Customizable layout and appearance
- Docker integration for container status

**Configuration**:
- Deployed via Docker Compose
- Accessible via Traefik at `https://homepage.local.rwdevs.com`
- Configuration files in `/mnt/docker/homepage/config`
- Supports custom templates and widgets

**Use Case**: Provides a centralized landing page for accessing all deployed services with status monitoring.

---

### MailRise

**Role**: `apps/mailrise` | **Playbook**: `mailrise.yml`

**Purpose**: SMTP-to-webhooks gateway for routing email alerts to various notification services.

**Key Features**:
- SMTP server for receiving alert emails
- Transforms emails to webhook calls
- Supports routing to Discord, Slack, Telegram, and other services
- Email alias routing and filtering
- No web UI (configuration-file driven)

**Configuration**:
- Deployed via Docker Compose
- SMTP port: 8025 (configurable)
- Configuration via mounted config file
- Credentials stored in Ansible Vault

**Use Case**: Converts system and application alerts received via email into notifications on the platforms you use (Discord, Slack, etc.).

---

### Watchtower

**Role**: `apps/watchtower` | **Playbook**: `watchtower.yml`

**Purpose**: Automatic container image update and deployment service.

**Key Features**:
- Monitors Docker registries for new image versions
- Automatically pulls and restarts containers with updated images
- Scheduled update checks (cron-based)
- Docker Compose stack support
- Cleanup of unused images
- Email or webhook notifications on updates

**Configuration**:
- Deployed via Docker Compose
- Runs on a schedule (default: daily at 2 AM)
- Can be configured for monitoring specific containers
- Notification settings in environment variables

**Use Case**: Ensures applications stay current with latest patches and features without manual intervention.

---

### Semaphore

**Role**: `apps/semaphore` | **Playbook**: `semaphore.yml`

**Purpose**: Web-based interface for running and managing Ansible playbooks with audit logging.

**Key Features**:
- GUI for executing Ansible playbooks
- Project management and repository integration
- Environment and inventory management
- Activity logging and audit trail
- User authentication and RBAC
- Task scheduling (one-time or recurring)
- Template support for common tasks
- Webhook integration for CI/CD

**Configuration**:
- Deployed via Docker Compose with PostgreSQL database
- Web interface on port 3000
- Persistent database in `/mnt/docker/semaphore/db`
- Accessible via Traefik at `https://semaphore.local.rwdevs.com`

**Use Case**: Provides a centralized control panel for running infrastructure automation tasks, enabling non-technical users to manage infrastructure changes.

## Variables & Configuration

### Global Variables (`vars/global.yml`)

Core configuration affecting all hosts and services:

```yaml
# Domain and networking
domain: local.rwdevs.com
docker_network: traefik

# Service endpoints
services:
  traefik: proxy.local.rwdevs.com
  portainer: portainer.local.rwdevs.com
  homepage: homepage.local.rwdevs.com
  pihole: pihole.local.rwdevs.com
  
# NFS storage
nfs_server: 192.168.1.100
nfs_mount_base: /mnt/docker
```

These variables are accessible in all roles and can be overridden at the playbook, group, or host level.

### Secrets (`vars/secrets.yml`)

Sensitive data managed via Ansible Vault:

```yaml
cloudflare_dns_api_token: "your-cloudflare-token"
portainer_admin_password: "your-password"
pihole_password: "your-password"
```

**Encrypt/Edit secrets**:

```bash
# Edit secrets (requires vault password)
ansible-vault edit vars/secrets.yml

# View secrets
ansible-vault view vars/secrets.yml

# Create new vault file
ansible-vault create vars/secrets.yml
```

**Vault Password**:

Store the vault password in `~/.ansible/vault_password` for automatic decryption:

```bash
echo "your-vault-password" > ~/.ansible/vault_password
chmod 600 ~/.ansible/vault_password
```

### Role-Specific Variables

Each role has `defaults/main.yml` with sensible defaults. Override in:

1. **Inventory file** (`inventories/docker.yml`) - Per-host or group variables
2. **Playbook vars section** - For specific playbook runs
3. **Host/Group var files** - In `inventories/group_vars/` or `inventories/host_vars/`

Example (inventory):

```yaml
all:
  hosts:
    docker-host01:
      traefik_tag: v3.6.1
      pihole_password: "{{ vault_pihole_password }}"
```

## Collections

Required collections provide additional modules for Docker, system management, and common tasks.

Install collections:

```bash
ansible-galaxy collection install -r collections/requirements.yml
```

Key collections:

- **community.docker** - Docker containers, images, networks, volumes
- **community.general** - General system modules (users, groups, systemd, etc.)
- **ansible.posix** - POSIX system modules

## Running from Terraform

Terraform configurations can trigger Ansible playbooks via `local-exec` provisioners after infrastructure is created:

```bash
# Run complete infrastructure provisioning
make apply

# Runs both Terraform and Ansible automatically
```

See the Terraform README for integration details.

## Troubleshooting

### Playbook Execution Issues

**Run in check mode (dry-run) to preview changes**:

```bash
ansible-playbook playbooks/traefik.yml -i inventories/docker.yml --check
```

**Enable verbose output for debugging**:

```bash
# Single level (-v)
ansible-playbook playbooks/traefik.yml -i inventories/docker.yml -v

# Multiple levels for more detail (-vv, -vvv, -vvvv)
ansible-playbook playbooks/traefik.yml -i inventories/docker.yml -vvv
```

**Test specific host or task**:

```bash
# Run playbook for single host only
ansible-playbook playbooks/docker.yml -i inventories/docker.yml -l docker-host01

# Run specific task only
ansible-playbook playbooks/docker.yml -i inventories/docker.yml -k docker.engine
```

### SSH and Connectivity Issues

**Test SSH connectivity to all hosts**:

```bash
ansible all -i inventories/docker.yml -m ping
```

**Debug SSH connection to specific host**:

```bash
ansible docker-host01 -i inventories/docker.yml -m debug -a "msg=test" -vvv
```

**Check if SSH keys are loaded**:

```bash
ssh-add -l

# Add key if needed
ssh-add ~/.ssh/id_rsa
```

### Vault and Encryption Issues

**If vault password is cached or not working**:

```bash
# Clear cached vault password
unset ANSIBLE_VAULT_PASSWORD_FILE

# Prompt for password on each run
ansible-playbook playbooks/traefik.yml -i inventories/docker.yml --ask-vault-pass

# Use password file
ansible-playbook playbooks/traefik.yml -i inventories/docker.yml \
  --vault-password-file ~/.ansible/vault_password
```

**If you forget the vault password**:

You will need to re-encrypt the `vars/secrets.yml` file and obtain the original secrets from your password manager or backup.

### Docker and Container Issues

**Check Docker is running on target host**:

```bash
ansible docker-host01 -i inventories/docker.yml -m shell -a "docker ps"
```

**View Docker Compose logs**:

```bash
# On the host directly
docker-compose -f /opt/traefik/docker-compose.yml logs -f
```

**Restart a service**:

```bash
ansible docker-host01 -i inventories/docker.yml -m shell \
  -a "docker-compose -f /opt/traefik/docker-compose.yml restart"
```

## Best Practices

1. **Test in check mode first** - Always run with `--check` before applying changes to production
2. **Use roles for reusability** - Encapsulate related tasks in roles with clear responsibilities
3. **Define defaults** - Set sensible defaults in `defaults/main.yml` for all variables
4. **Use vault for secrets** - Never commit passwords, tokens, or API keys in plain text
5. **Document configurations** - Keep role README.md files updated with variable descriptions
6. **Use handlers for restarts** - Minimize service disruption by batching restarts
7. **Make playbooks idempotent** - Playbooks should safely re-run without side effects
8. **Use tags for targeted runs** - Group tasks with tags to run specific portions
9. **Version control** - Commit all playbooks and roles to version control
10. **Test locally first** - Use a test VM or container before applying to production

## Workflow Examples

### Complete Initial Server Setup

```bash
# 1. Configure base system
ansible-playbook playbooks/base.yml -i inventories/docker.yml

# 2. Install Docker
ansible-playbook playbooks/docker.yml -i inventories/docker.yml

# 3. Setup storage
ansible-playbook playbooks/storage.yml -i inventories/docker.yml

# 4. Deploy reverse proxy
ansible-playbook playbooks/traefik.yml -i inventories/docker.yml

# 5. Deploy applications
ansible-playbook playbooks/portainer.yml -i inventories/docker.yml
ansible-playbook playbooks/pihole.yml -i inventories/docker.yml
ansible-playbook playbooks/homepage.yml -i inventories/docker.yml
```

### Update Existing Application

```bash
# Update single application
ansible-playbook playbooks/portainer.yml -i inventories/docker.yml \
  -e "portainer_update=true"
```

### System Maintenance

```bash
# Apply latest OS updates
ansible-playbook playbooks/system_updates.yml -i inventories/docker.yml
```

### Add New Host to Inventory

```yaml
# inventories/docker.yml
all:
  hosts:
    docker-host01:
      ansible_host: 192.168.1.10
      ansible_user: ubuntu
      ansible_ssh_private_key_file: ~/.ssh/id_rsa
```

Then run base setup:

```bash
ansible-playbook playbooks/base.yml -i inventories/docker.yml -l docker-host01
```

## Resources

- [Ansible Documentation](https://docs.ansible.com/)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/tips_tricks/index.html)
- [Community Ansible Collections](https://galaxy.ansible.com/collections)
- [Docker Ansible Module Documentation](https://docs.ansible.com/ansible/latest/collections/community/docker/index.html)

### Role Documentation

- [Traefik Role](roles/apps/traefik/README.md)
- [Portainer Role](roles/apps/portainer/README.md)
- [Pi-hole Role](roles/apps/pihole/README.md)
- [Homepage Role](roles/apps/homepage/README.md)
- [MailRise Role](roles/apps/mailrise/README.md)
- [Watchtower Role](roles/apps/watchtower/README.md)
- [Semaphore Role](roles/apps/semaphore/README.md)
