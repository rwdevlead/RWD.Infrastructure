# base/ssh

Safely configures OpenSSH server.

## Responsibilities

- Harden SSH configuration
- Explicitly allow root login
- Allow managed user login
- Restart SSH safely with config validation

## Variables

| Variable                    | Description           |
| --------------------------- | --------------------- |
| ssh_port                    | SSH listening port    |
| ssh_permit_root_login       | yes / no              |
| ssh_password_authentication | Enable password login |
| ssh_allow_users             | Allowed SSH users     |

## Safety

- Uses sshd config validation
- Root login explicitly allowed
- No firewall changes
