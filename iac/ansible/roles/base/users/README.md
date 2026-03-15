# base/users

Manages a single non-root system user.

## Responsibilities

- Ensures user exists
- Manages password (hashed)
- Manages SSH authorized keys
- Configures sudo access

## Does NOT

- Modify SSH daemon config
- Disable or restrict root
- Create multiple users

## Variables

| Variable                | Description              |
| ----------------------- | ------------------------ |
| base_user_name          | Username to manage       |
| base_user_password_hash | SHA-512 password hash    |
| base_user_ssh_keys      | List of public SSH keys  |
| base_user_sudo_nopasswd | Enable passwordless sudo |

## Example

```yaml
base_user_name: ka8kgj
base_user_sudo_nopasswd: true
base_user_ssh_keys:
  - ssh-ed25519 AAAA...
```

```code
---

## How This Is Used

### CLI
ansible-playbook \
  -i inventories/base/hosts.yml \
  playbooks/base.yml

```
