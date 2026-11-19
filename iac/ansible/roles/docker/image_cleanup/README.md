# docker/image_cleanup

Prunes unused/dangling Docker images on `docker_hosts` using `community.docker.docker_prune`.

---

## Requirements

- Docker Engine installed and running (via `docker/engine`)
- `community.docker` Ansible collection

---

## Variables

### Role Defaults (`defaults/main.yml`)

| Variable | Description | Default |
| :--- | :--- | :--- |
| `image_cleanup_dangling_only` | Prune only untagged/dangling images when `true`; prune all unused images when `false` | `true` |
| `image_cleanup_filters` | Optional extra `docker_prune` image filters (e.g., `{"until": "24h"}`) | `{}` |

---

## Infisical Secrets

None.

---

## Dependencies

- `community.docker` collection

---

## Example

```yaml
- name: Clean up unused Docker images
  hosts: docker_hosts
  become: true
  roles:
    - docker/image_cleanup
```

---

## Make Targets

```bash
make docker-cleanup-check
make docker-cleanup
```

---

## Notes

- Skipped automatically during `--check` dry-runs (`when: not ansible_check_mode`).
- Included at the end of [playbooks/pihole.yml](../../../playbooks/pihole.yml) to remove orphaned images left behind after `pull: always` upgrades.
