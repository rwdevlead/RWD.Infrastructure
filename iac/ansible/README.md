# Ansible Configuration Management

Ansible automates post-provisioning OS configuration, Docker platform setup, containerized application deployments, TrueNAS storage provisioning, and Proxmox UPS/NUT orchestration for `RWD.Infrastructure`.

All playbooks should be invoked from the repository root via the root [Makefile](../../Makefile), which exports `ANSIBLE_CONFIG=iac/ansible/ansible.cfg` and loads `.env` (including Infisical Universal Auth credentials).

---

## Directory Layout

```text
iac/ansible/
├── ansible.cfg                  # Portable relative paths, YAML output, SSH settings
├── collections/
│   └── requirements.yml         # Required Galaxy collections (community.docker, infisical.vault)
├── inventories/
│   ├── README.md                # Inventory & group_vars documentation
│   ├── hosts.yml                # Docker hosts, service groups, and Proxmox cluster
│   ├── truenas.yml              # TrueNAS target inventory
│   └── group_vars/
│       ├── all.yml              # Loads iac/shared/infrastructure.yml dynamically
│       ├── docker_hosts.yml     # Shared Docker, NFS, security, and app instance vars
│       └── proxmox_cluster.yml  # Proxmox root SSH user and NUT cluster topology
├── playbooks/
│   ├── README.md                # Index of all 16 playbooks and Makefile targets
│   └── *.yml                    # Service, base, maintenance, and test playbooks
└── roles/
    ├── README.md                # Role categories, conventions, and role index
    ├── infisical_secrets/       # Infisical Universal Auth secret loader
    ├── system_base/             # Hostname, security, SSH, and user setup
    ├── docker/                  # NFS mounts, Docker engine, and Docker Compose
    ├── proxmox/                 # Proxmox host automation (nut)
    ├── truenas/                 # TrueNAS ZFS pool, dataset, and share setup (nas_config)
    └── apps/                    # Containerized application stacks
```

See also:
- [Inventories & Group Vars](inventories/README.md)
- [Playbooks Index](playbooks/README.md)
- [Roles Index](roles/README.md)

---

## Prerequisites & Setup

### 1. Install Ansible and Collections

```bash
# macOS (Homebrew)
brew install ansible

# Install required collections into ./collections or ~/.ansible/collections
ansible-galaxy collection install -r iac/ansible/collections/requirements.yml
```

Required collections ([collections/requirements.yml](collections/requirements.yml)):
- `community.docker` — Docker daemon, container, and Compose orchestration
- `infisical.vault` — Runtime secret retrieval from Infisical

### 2. Configure Infisical Authentication

Secrets are never stored in Ansible Vault files or committed to git. Roles that require credentials invoke `infisical_secrets` (backed by `infisical.vault`) using Universal Auth environment variables loaded by the root `Makefile` from `.env`:

- `INFISICAL_CLIENT_ID`
- `INFISICAL_CLIENT_SECRET`
- `INFISICAL_PROJECT_ID`

Verify configuration and Infisical connectivity from the repository root:

```bash
make ansible-config
make test-infisical
```

> [!NOTE]
> On macOS, `make test-infisical` sets `OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES` to prevent Python/Objective-C fork crashes during local lookup execution.

### 3. `ansible.cfg` Behavior

[ansible.cfg](ansible.cfg) uses relative paths (`./collections:~/.ansible/collections`, `./inventories`, `./roles`) so playbooks work across machines without hardcoded user paths. The root `Makefile` sets `export ANSIBLE_CONFIG=$(ANSIBLE_DIR)/ansible.cfg`.

For homelab convenience, `[defaults]` sets `host_key_checking = False` and `[ssh_connection]` sets `host_key_auto_add = True` with `ssh_args = -o PasswordAuthentication=yes -o StrictHostKeyChecking=no` (useful for initial bootstrap before key hardening).

---

## Shared Topology & Variable Precedence

Non-secret network, Proxmox node, and VM topology is maintained once in [iac/shared/infrastructure.yml](../shared/infrastructure.yml) and shared with Terraform.

Ansible loads that file dynamically via [inventories/group_vars/all.yml](inventories/group_vars/all.yml) (`lookup('ansible.builtin.file', ...) | from_yaml`), exposing `network`, `proxmox_nodes`, and `vms` across every inventory.

Variables resolve in standard Ansible precedence order (lowest to highest):

1. `roles/<category>/<role>/defaults/main.yml` — Role-level constants and defaults
2. `inventories/group_vars/all.yml` — Shared topology (`network`, `proxmox_nodes`, `vms`)
3. `inventories/group_vars/docker_hosts.yml` / `proxmox_cluster.yml` — Group-specific config and service maps
4. `inventories/hosts.yml` / `truenas.yml` — Host group membership and `ansible_host` / SSH overrides
5. `playbooks/<playbook>.yml` (`vars:`) — Playbook overrides (such as `infisical_secret_paths`)
6. Runtime facts (`secrets.*` set by `infisical_secrets` and command-line `-e` overrides)

---

## Step-by-Step Workflow

Always run the `-check` target (`--check --diff`) before applying changes.

### 1. Validate Tooling & Secrets

```bash
make ansible-config
make test-infisical
```

### 2. Provision a New Docker Host

Run base setup, Docker platform setup, and OS update automation in order:

```bash
# 1. Base OS configuration (hostname, firewall/fail2ban/sysctl)
make base-check
make base

# 2. Docker platform (hostname, /mnt/docker NFS mount, Docker CE, Compose)
make docker-check
make docker

# 3. Unattended security upgrades & Mailrise relay alerts
make setup-updates
```

> [!IMPORTANT]
> Check the `Makefile` targets before running against multiple hosts: `make docker`, `make setup-updates`, and `make run-upgrade` currently pass `--limit dev-docker-02`.

### 3. Deploy Application Stacks

Deploy services in dependency order (reverse proxy / DNS / notifications before dependent apps):

```bash
# Core infrastructure services
make traefik-check   && make traefik
make mailrise-check  && make mailrise
make pihole-check    && make pihole
make nebula-check    && make nebula

# Management & observability
make portainer-check       && make portainer
make portainer-agent-check && make portainer-agent
make homarr-check          && make homarr
make uptime-kuma-check     && make uptime-kuma
make pulse-check           && make pulse
make watchtower-check      && make watchtower
```

> [!NOTE]
> `pihole.yml` runs a `showmount -e` pre-task against `dev-truenas-01` and fails fast if the host's `/mnt/tank/docker/<inventory_hostname>` NFS export is missing.

### 4. TrueNAS Storage & Proxmox UPS/NUT

```bash
# TrueNAS pool, datasets, and NFS/SMB shares (uses inventories/truenas.yml)
make truenas-check
make truenas

# Proxmox cluster UPS/NUT orchestration (uses proxmox_cluster group)
make ups-nut-check
make ups-nut
```

### 5. Targeting a Single Host or Manual Upgrade

For ad-hoc single-host runs or verbose debugging, invoke `ansible-playbook` with `ANSIBLE_CONFIG=iac/ansible/ansible.cfg`:

```bash
ANSIBLE_CONFIG=iac/ansible/ansible.cfg ansible-playbook iac/ansible/playbooks/docker.yml \
  -i iac/ansible/inventories/hosts.yml --limit prod-docker-01 --check --diff

# Manual dist-upgrade + conditional reboot (tagged never, manual_upgrade)
make run-upgrade
```

---

## Troubleshooting

- **Missing collections (`community.docker` or `infisical.vault`):** Re-run `ansible-galaxy collection install -r iac/ansible/collections/requirements.yml`.
- **Infisical auth errors:** Verify `.env` contains `INFISICAL_CLIENT_ID`, `INFISICAL_CLIENT_SECRET`, and `INFISICAL_PROJECT_ID`, then run `make test-infisical`.
- **Check-mode (`--check`) failures on first run:** Tasks that read files or query services installed earlier in the same play (or `showmount` checks when NFS is unreachable) may fail in dry-run mode on an unprovisioned host.
- **macOS fork crashes:** Export `OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES` when running local lookup plugins outside `make test-infisical`.
