# system_base/hostname

Preserves and applies the target system hostname by disabling Cloud-Init hostname overrides, updating `hostnamectl`, `/etc/hostname`, and `/etc/hosts` (`127.0.1.1`).

---

## Requirements

- Linux host with `systemd` (`hostnamectl`)

---

## Variables

| Variable | Description | Default |
| :--- | :--- | :--- |
| `new_hostname` | Target hostname to apply | `"{{ inventory_hostname }}"` |

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
  roles:
    - system_base/hostname
```

---

## Make Targets

```bash
make base-check
make base
```

---

## Notes

- Writes `/etc/cloud/cloud.cfg.d/99_preserve_hostname.cfg` with `preserve_hostname: true` so cloud-init does not revert the hostname on reboot.
- Also invoked as the first role in `playbooks/docker.yml`.
