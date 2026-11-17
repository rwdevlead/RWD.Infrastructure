# system_base/users

Manages a non-root administrative user, group memberships, authorized SSH keys, and validated `/etc/sudoers.d/<user>` configuration.

---

## Requirements

- Linux host with `sudo` and `visudo`

---

## Variables

### Role Defaults (`defaults/main.yml`) and Vars (`vars/main.yml`)

| Variable | Description | Default |
| :--- | :--- | :--- |
| `base_user_name` | Username to create/manage | `ansible` |
| `base_user_shell` | Login shell | `/bin/bash` |
| `base_user_groups` | Groups assigned to the user | `['sudo']` |
| `base_user_password_hash` | Pre-hashed SHA-512 password (`mkpasswd --method=SHA-512`) | `null` |
| `base_user_ssh_keys` | List of authorized SSH public keys | `[]` |
| `base_user_sudo_nopasswd` | Grant passwordless `sudo` | `false` |
| `sudoers_dir` | Target directory for sudoers drop-in (`vars/main.yml`) | `/etc/sudoers.d` |

---

## Infisical Secrets

None.

---

## Dependencies

None.

---

## Example

```yaml
- hosts: all
  become: true
  vars:
    base_user_name: ka8kgj
    base_user_sudo_nopasswd: true
    base_user_ssh_keys:
      - "ssh-ed25519 AAAA..."
  roles:
    - system_base/users
```

---

## Make Targets

```bash
make base-check
make base
```

---

## Notes

- Validates the generated sudoers file with `visudo -cf %s`.
- Does not modify `/etc/ssh/sshd_config` or disable `root`.
- Currently commented out in `playbooks/system_base.yml`.
