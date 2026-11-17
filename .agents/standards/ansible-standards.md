# Ansible Standards — RWD.Infrastructure

These standards govern Ansible roles, playbooks, inventories, Jinja2 templates, and Make targets under `iac/ansible/`.

---

## 1. Directory & Role Categorization

Place roles under the matching functional category in `iac/ansible/roles/`:

- `infisical_secrets/` — Vault authentication and secret merging (`infisical.vault`)
- `system_base/` — Baseline OS configuration (`hostname`, `security`, `ssh`, `users`)
- `docker/` — Container runtime and shared storage (`nfs-mounts`, `engine`, `compose`)
- `proxmox/` — Proxmox VE host-level automation (`nut`)
- `truenas/` — TrueNAS SCALE storage automation (`nas_config`)
- `apps/` — Containerized Docker Compose/container services

Standard role layout:

```text
roles/<category>/<role_name>/
├── README.md
├── defaults/main.yml
├── tasks/main.yml
├── handlers/main.yml     # If services need reload/restart
├── templates/*.j2        # Jinja2 templates
└── files/                # Static files/scripts (if needed)
```

---

## 2. Variable Hierarchy & Naming

- **Role defaults (`defaults/main.yml`):**
  - Prefix every role variable with `<role>_*` (`nut_port`, `traefik_tag`, `pulse_base_dir`).
  - Keep `defaults/main.yml` strictly for role-level constants (ports, versions, timers, directory templates).
  - Never hardcode hostnames, VM names, or environment IPs in role defaults or templates.
- **Host & service topology (`inventories/group_vars/`):**
  - Store per-host/per-instance configuration in `group_vars/docker_hosts.yml` or `group_vars/proxmox_cluster.yml`, keyed by `inventory_hostname` (e.g., `pihole_instances[inventory_hostname]`, `nut_instances[inventory_hostname]`).
  - Pull shared IPs, subnets, node aliases, and VM IDs from `iac/shared/infrastructure.yml` (loaded via `inventories/group_vars/all.yml`).
- **Playbooks (`playbooks/`):**
  - Use `snake_case` filenames (`deploy_nas_storage.yml`, `nebula_sync.yml`).
  - Declare `infisical_secret_paths` in playbook `vars:` and run `infisical_secrets` before roles that consume `secrets.*`.

---

## 3. Secrets & Sensitive Output

- Retrieve all secrets at runtime via `infisical_secrets` (`secrets.ansible.<path>.<KEY>`). Never commit Ansible Vault files, plaintext tokens, passwords, or PII emails in defaults or templates.
- Set `no_log: true` and/or `diff: false` on tasks that template or write credential-bearing files (`upsd.users`, `upsmon.conf`, etc.) so `--check --diff` never leaks secrets to terminal output.
- Never add debug tasks that print `secrets` or `read_results`.

---

## 4. Tasks, Handlers & Check-Mode Rules

- **FQCN Modules:** Always use fully qualified collection names (`ansible.builtin.file`, `ansible.builtin.template`, `community.docker.docker_compose_v2`, `community.docker.docker_container_info`).
- **Task Names:** Start with an imperative action verb (`Ensure`, `Install`, `Render`, `Deploy`, `Wait for`, `Verify`).
- **Handlers:** Use capitalized descriptive names (`Restart Traefik`, `Reload systemd`, `Restart NUT server`).
- **Idempotency & Shell Tasks:** Prefer declarative modules over `shell`/`command`. When `shell`/`command` is required, set `changed_when` and `failed_when` explicitly and add an inline "why" comment.
- **Check Mode (`--check`):** Guard mutating runtime actions, container starts, and live health assertions with `when: not ansible_check_mode`. If a preflight check or directory/template step uses `check_mode: false`, add an inline comment explaining why.

---

## 5. Docker Application Role Pattern

Follow this sequence in `roles/apps/<app>/tasks/main.yml`:

1. Create host base/data directories (`ansible.builtin.file` with explicit owner/group/mode).
2. Ensure external `{{ shared_docker_network }}` (`traefik`) exists if needed.
3. Render `docker-compose.yml.j2` (and app config templates) with `notify: Restart <App>`.
4. Deploy with `community.docker.docker_compose_v2` (`when: not ansible_check_mode`).
5. Verify container health (`community.docker.docker_container_info`) and/or HTTP endpoint (`ansible.builtin.uri`) + `ansible.builtin.assert` (`when: not ansible_check_mode`).

---

## 6. Jinja2 Template & Makefile Rules

- **Jinja2:** Keep `#!/bin/bash` on **line 1** of script templates (place `{% set ... %}` blocks below the shebang unless whitespace control `{%- ... -%}` prevents leading blank lines). Use `{# ... #}` for template-only comments and `# ...` for rendered comments. Quote CLI inputs with `| quote` where appropriate.
- **Makefile Pairs:** Every playbook must have paired `<target>-check` (`--check --diff`) and `<target>` rules in the root `Makefile`, declared under `.PHONY` with `##` help descriptions.
- **Documentation:** Update the role `README.md`, `roles/README.md`, and `playbooks/README.md` in the same change set using `.agents/templates/ansible-role-readme-template.md`.
