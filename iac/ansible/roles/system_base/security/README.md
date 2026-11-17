# system_base/security

Applies baseline Linux security hardening: Fail2ban SSH protection, light kernel `sysctl` tuning, and optional UFW firewall rules.

---

## Requirements

- Linux host with `apt`/package manager and `systemd`
- `ssh_port` defined when `security_firewall_enabled` and `firewall_allow_ssh` are `true` (defined in `group_vars/docker_hosts.yml` and `system_base/ssh`)

---

## Variables

### Role Defaults (`defaults/main.yml`)

| Variable | Description | Default |
| :--- | :--- | :--- |
| `security_fail2ban_enabled` | Install and enable Fail2ban SSH jail | `true` |
| `security_sysctl_enabled` | Apply `sysctl` network hardening parameters | `true` |
| `security_firewall_enabled` | Install and enable UFW firewall | `false` *(overridden to `true` in `group_vars/docker_hosts.yml`)* |
| `fail2ban_bantime` | Fail2ban ban duration | `1h` |
| `fail2ban_findtime` | Fail2ban failure window | `10m` |
| `fail2ban_maxretry` | Failed attempts before ban | `5` |
| `firewall_allow_ssh` | Allow TCP `ssh_port` in UFW | `true` |
| `firewall_allow_ports` | Additional ports/rules allowed in UFW | `[]` |
| `sysctl_settings` | Map of `sysctl` keys/values to enforce | Disables ICMP redirects (`accept_redirects`/`send_redirects = 0`) and ignores ICMP broadcasts (`1`) |

---

## Infisical Secrets

None.

---

## Dependencies

None (`ssh_port` must be defined if UFW is enabled with `firewall_allow_ssh: true`).

---

## Example

```yaml
- hosts: all
  become: true
  roles:
    - system_base/security
```

---

## Make Targets

```bash
make base-check
make base
```

---

## Notes

- `group_vars/docker_hosts.yml` sets `security_firewall_enabled: true` and `ssh_port: 22`; UFW defaults to `policy: allow` while explicitly allowing `ssh_port` and `firewall_allow_ports`.
- The `Restart fail2ban` handler skips execution in `--check` mode.
