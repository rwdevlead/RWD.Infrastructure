# docker/engine

Installs Docker Community Edition and plugins via Docker's DEB822 apt repository, configures Docker to wait for `/mnt/docker` on boot, adds configured users to the `docker` group, and disables the `systemd-resolved` stub listener.

---

## Requirements

- Ubuntu/Debian host with `apt`
- `/mnt/docker` mount unit (`mnt-docker.mount`, typically configured by `docker/nfs-mounts`)
- `docker_users` defined (configured in `inventories/group_vars/docker_hosts.yml`)

---

## Variables

| Variable | Description | Source / Default |
| :--- | :--- | :--- |
| `docker_users` | List of users added to the `docker` group | `[]` in `defaults/main.yml` (overridden in `inventories/group_vars/docker_hosts.yml` as `["ka8kgj"]`) |

---

## Infisical Secrets

None.

---

## Dependencies

- Intended to run after `docker/nfs-mounts` in `playbooks/docker.yml`.

---

## Example

```yaml
- hosts: docker_hosts
  become: true
  roles:
    - docker/engine
```

---

## Make Targets

```bash
make docker-check
make docker
```

---

## Notes

- Removes legacy `/etc/apt/sources.list.d/docker.list` and `/etc/apt/keyrings/docker.gpg`, adds `/etc/apt/keyrings/docker.asc`, and writes `/etc/apt/sources.list.d/docker.sources` (runs even in `--check` mode).
- Creates `/etc/systemd/system/docker.service.d/override.conf` with `Requires=mnt-docker.mount` and `After=mnt-docker.mount`. (Note: `tasks/main.yml` notifies `Restart Docker daemon` while `handlers/main.yml` defines `Restart Docker`.)
- Sets `DNSStubListener=no` in `/etc/systemd/resolved.conf` and symlinks `/etc/resolv.conf` to `/run/systemd/resolve/resolv.conf` so Pi-hole can bind port 53 cleanly.
- Users must start a new shell/session for `docker` group membership to take effect.
