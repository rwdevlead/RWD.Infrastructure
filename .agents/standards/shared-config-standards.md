# Shared Configuration & Secret Placement Standards

These standards define the single source of truth (`iac/shared/infrastructure.yml`), where configuration values live, and conventions for root orchestration scripts.

---

## 1. Single Source of Truth (`iac/shared/infrastructure.yml`)

All non-secret network, Proxmox node, and VM topology shared between Terraform and Ansible lives in [iac/shared/infrastructure.yml](../../iac/shared/infrastructure.yml):

- `network`: `subnet`, `prefix`, `gateway`, `domain`
- `proxmox_nodes`: keyed by node name (`pve-d01`, `pve-p01`, `proxmox`) with `alias` and `ip`
- `vms`: keyed by VM name with `vm_id`, `node`, and `ip`

### Consumption Rules (No Symlinks)

- **Terraform:** Each Proxmox environment loads it in `locals.tf`:
  ```hcl
  infra = yamldecode(file("${path.module}/../../../../shared/infrastructure.yml"))
  ```
- **Ansible:** `iac/ansible/inventories/group_vars/all.yml` loads it dynamically for every inventory:
  ```yaml
  _shared_infra: "{{ lookup('ansible.builtin.file', inventory_dir ~ '/../../shared/infrastructure.yml') | from_yaml }}"
  network: "{{ _shared_infra.network }}"
  proxmox_nodes: "{{ _shared_infra.proxmox_nodes }}"
  vms: "{{ _shared_infra.vms }}"
  ```
- Never duplicate IPs, VM IDs, node names, or subnets across Terraform `.tf` files and Ansible inventories/templates. Never use symlinks to share config files.

---

## 2. Where Values Belong (Placement Matrix)

| Value Type | Canonical Location | Examples |
| :--- | :--- | :--- |
| Non-secret network, node, and VM topology | `iac/shared/infrastructure.yml` | Subnet, gateway, domain, Proxmox node IPs/aliases, VM IDs/IPs |
| Ansible host/service topology & non-secret app metadata | `iac/ansible/inventories/group_vars/` | `pihole_instances`, `nut_instances`, `traefik_instance`, `mailrise.port` |
| Role-level constants & behavioral toggles | `roles/<cat>/<role>/defaults/main.yml` | Image names/tags, container ports, timeouts, retry counts, config dirs |
| Passwords, API tokens, keys, PII emails, push URLs with tokens | **Infisical** | `CF_DNS_API_TOKEN`, `ACME_EMAIL`, `NEBULA_PUSH_TOKEN`, `AGENT_SECRET`, `PVE_TOKEN` |
| Machine auth bootstrap & local TF fallback | `.env` (gitignored, documented in `.env.example`) | `INFISICAL_CLIENT_ID`, `INFISICAL_CLIENT_SECRET`, `INFISICAL_PROJECT_ID` |
| Terraform Cloud user API token | `~/.terraform.d/credentials.tfrc.json` (`terraform login`) | HCP Terraform CLI auth only (never in Infisical or git) |

---

## 3. Root `Makefile` & Shell Script Conventions

- **Makefile:**
  - Keep Ansible targets in `<target>-check` (`--check --diff`) and `<target>` pairs.
  - Register all non-file targets under `.PHONY` and include `## <summary>` comments for `make help`.
  - Add concise "why" comments for macOS workarounds (`OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES`) or intentional host `--limit` scoping.
- **Shell Scripts (`cleanup_vm.sh`, `convert_to_template.sh`):**
  - Start with `#!/usr/bin/env bash` and `set -euo pipefail`.
  - Validate required environment variables with `${VAR:?message}` parameter expansion.
  - Quote all variable expansions (`"${VAR}"`) and explain non-obvious flags or destructive operations (`truncate -s 0 /etc/machine-id`, `StrictHostKeyChecking=no`, polling loops) with "why" comments.
