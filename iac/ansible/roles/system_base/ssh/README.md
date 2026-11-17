# system_base/ssh

Installs OpenSSH server and deploys a validated `/etc/ssh/sshd_config`.

---

## Requirements

- Linux host with OpenSSH (`openssh-server`)
- `base_user_name` defined (referenced in `ssh_allow_users` default, e.g., via `system_base/users` or inventory/group vars)

---

## Variables

### Role Defaults (`defaults/main.yml`)

| Variable | Description | Default |
| :--- | :--- | :--- |
| `ssh_port` | SSH daemon listening port | `22` |
| `ssh_permit_root_login` | `PermitRootLogin` setting (`yes` / `no`) | `"yes"` |
| `ssh_password_authentication` | Allow password authentication | `false` |
| `ssh_pubkey_authentication` | Allow public-key authentication | `true` |
| `ssh_permit_empty_passwords` | Allow empty passwords | `false` |
| `ssh_max_auth_tries` | Maximum auth attempts per connection | `3` |
| `ssh_login_grace_time` | Authentication grace period (seconds) | `30` |
| `ssh_allow_users` | `AllowUsers` list | `["{{ base_user_name }}", "root"]` |

---

## Infisical Secrets

None.

---

## Dependencies

- `base_user_name` (from `system_base/users` or host/group variables) unless `ssh_allow_users` is overridden.

---

## Example

```yaml
- hosts: all
  become: true
  roles:
    - system_base/users
    - system_base/ssh
```

---

## Make Targets

```bash
make base-check
make base
```

---

## Notes

- Validates the rendered config with `/usr/sbin/sshd -t -f %s` before overwriting `/etc/ssh/sshd_config`.
- Currently commented out in `playbooks/system_base.yml`.
