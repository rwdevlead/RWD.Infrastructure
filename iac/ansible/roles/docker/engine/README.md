# docker/engine

Installs and configures Docker Engine.

## Responsibilities

- Install Docker CE and dependencies
- Configure daemon.json
- Enable Docker service
- Add managed user to docker group

## Variables

| Variable             | Description                   |
| -------------------- | ----------------------------- |
| docker_daemon_config | Docker daemon.json contents   |
| docker_manage_user   | Add base user to docker group |
| docker_user          | User added to docker group    |

## Notes

- Requires base/users role to run first
- User must re-login for group membership to apply
