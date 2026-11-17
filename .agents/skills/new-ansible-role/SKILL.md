---
name: new-ansible-role
description: Scaffold a new Ansible role, playbook, Makefile target pair, and README following RWD.Infrastructure standards. Trigger with "/new-ansible-role".
argument-hint: "<category>/<role_name> (e.g. apps/homepage)"
---

# Purpose

Create a complete, standards-compliant Ansible role, playbook, `Makefile` `<target>-check` / `<target>` pair, and documentation using `.agents/standards/ansible-standards.md` and `.agents/templates/`.

---

## Step 1 — Gather & Validate Inputs

1. Read `.agents/standards/ansible-standards.md` and `.agents/standards/shared-config-standards.md`.
2. Confirm the role category (`apps`, `docker`, `proxmox`, `system_base`, `truenas`), role name, target inventory host/group, and whether Infisical secrets are needed.
3. Propose the exact files to create/modify and wait for user confirmation before writing.

---

## Step 2 — Scaffold Role, Playbook & Make Targets

Using `.agents/templates/ansible-role-skeleton.md`:

1. Create `iac/ansible/roles/<category>/<role>/`:
   - `defaults/main.yml` — role-prefixed constants (`<role>_*`) only; no hardcoded IPs/hostnames.
   - `tasks/main.yml` — FQCN modules, imperative task names, `when: not ansible_check_mode` on runtime deploys/health checks, `no_log: true` / `diff: false` on credential tasks.
   - `handlers/main.yml` — capitalized handler names (e.g., `Restart <App>`).
   - `templates/*.j2` — keep `#!/bin/bash` on line 1 for scripts; pull host metadata from `group_vars` and `iac/shared/infrastructure.yml`.
2. Create `iac/ansible/playbooks/<playbook>.yml` (include `infisical_secret_paths` and `infisical_secrets` if credentials are required).
3. Update `iac/ansible/inventories/hosts.yml` and `inventories/group_vars/` with any host group or service instance metadata.
4. Add `<target>-check` (`--check --diff`) and `<target>` to the root `Makefile` and register both under `.PHONY`.

---

## Step 3 — Document & Verify

1. Write `iac/ansible/roles/<category>/<role>/README.md` using `.agents/templates/ansible-role-readme-template.md`.
2. Update `iac/ansible/roles/README.md`, `iac/ansible/roles/<category>/README.md`, and `iac/ansible/playbooks/README.md`.
3. With user approval, run `make <target>-check` against the target host/group to verify dry-run behavior cleanly.
