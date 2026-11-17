# Base System Roles (`system_base/`)

Roles under `iac/ansible/roles/system_base/` handle baseline Linux host configuration: hostname persistence, security hardening, SSH daemon hardening, and administrative user management.

---

## Roles

| Role | Purpose | Status in `playbooks/system_base.yml` |
| :--- | :--- | :--- |
| [`system_base/hostname`](hostname/README.md) | Disables cloud-init hostname override, sets static hostname and `/etc/hosts` | Active |
| [`system_base/security`](security/README.md) | Configures fail2ban, sysctl hardening, and optional UFW firewall | Active |
| [`system_base/ssh`](ssh/README.md) | Configures hardened `sshd_config` with `sshd -t` validation | Commented out |
| [`system_base/users`](users/README.md) | Creates non-root admin user, SSH keys, and sudoers entry | Commented out |

---

## Make Targets

```bash
# Dry-run base system setup across all hosts in inventories/hosts.yml
make base-check

# Apply base system setup
make base
```
