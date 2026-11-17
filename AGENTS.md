# AGENTS.md — RWD.Infrastructure

This file defines the project instructions, conventions, and operational workflows for AI agents working in this repository.

---

## 1. Project Overview & Architecture

- **Project:** RWD.Infrastructure
- **Purpose:** Infrastructure as Code (IaC) repository for provisioning, configuring, and managing Real World Developers infrastructure (Proxmox VMs, network, storage, containers, and services).
- **Core Tooling:**
  - **Terraform:** Declarative infrastructure provisioning under `iac/terraform/` (environments and reusable modules).
  - **Ansible:** Configuration management, playbooks, and server roles under `iac/ansible/`.
  - **Makefile:** Universal workflow orchestration for Terraform and Ansible actions.
  - **Secrets Management:** Infisical (`.env` overrides mapped to `TF_VAR_*`).

---

## 2. Directory Map & Key Files

- `iac/shared/infrastructure.yml`: Single source of truth for non-secret network, Proxmox node, and VM topology shared by Terraform and Ansible.
- `iac/terraform/environments/`: Target-specific Terraform roots (e.g. `proxmox/pve-p01`, `github/realworlddevelopers`, `infisical`).
- `iac/terraform/modules/`: Reusable Terraform modules (`github/`, `proxmox/`).
- `iac/ansible/playbooks/`: Ansible playbooks for service provisioning, storage, UPS/NUT, and node configurations.
- `iac/ansible/roles/`: Modular Ansible roles (`infisical_secrets`, `system_base`, `docker`, `proxmox`, `truenas`, `apps`).
- `iac/ansible/inventories/`: Environment inventories (`hosts.yml`, `truenas.yml`) and `group_vars/` (`all.yml` loads `iac/shared/infrastructure.yml`).
- `Makefile`: Universal entry point for all IaC operations (Terraform `init`/`plan`/`apply`/`validate`/`fmt`/`clean`/`destroy`, and Ansible `<target>-check`/`<target>`).
- `.agents/standards/`: Mandatory workflow, coding, git/PR, and documentation standards.
- `.agents/memory/`: Project long-term context (`PROJECT_CONTEXT.md`) and session handoff (`AI_HANDOFF.md`).
- `.agents/skills/`: Agent skills (`/commit-cleanup`, `/create-pr`, `/generate-docs`, `/handoff`, `/project-ai-refresh`, `/project-ai-setup`, `/refactor-code`, `/review`).

---

## 3. Verified Build & Run Commands

- **Help & Available Targets:** `make help`
- **Terraform Init:** `make init TARGET=<env-path>` (e.g. `TARGET=proxmox/pve-p01`)
- **Terraform Plan:** `make plan TARGET=<env-path>`
- **Terraform Apply:** `make apply TARGET=<env-path>`
- **Terraform Validate / Format:** `make validate TARGET=<env-path>` / `make fmt TARGET=<env-path>`
- **Ansible Config & Infisical Check:** `make ansible-config` / `make test-infisical`
- **Ansible Dry-Run / Apply:** `make <target>-check` / `make <target>` (e.g. `make docker-check`, `make traefik-check`, `make ups-nut-check`)

---

## 4. Working Principles & Standards

All agents must follow the standards located in `.agents/standards/`:
- **Git & PR Standards:** Refer to [.agents/standards/git-and-pr-standards.md](.agents/standards/git-and-pr-standards.md). Branch protection prohibits direct commits to `main`. Follow Conventional Commits, provide squash-merge commit logs, and prepare PRs via git with server-side completion.
- **Workflow Standards:** Refer to [.agents/standards/workflow-standards.md](.agents/standards/workflow-standards.md). Follow the 5-phase SDLC (`Orient` -> `Plan` -> `Execute` -> `Verify` -> `Hand Off`).
- **Coding & IaC Standards:** Refer to [.agents/standards/coding-standards.md](.agents/standards/coding-standards.md). Keep Terraform modules modular and idempotent. Never commit secrets, credentials, or `.env` files.
- **Documentation Standards:** Refer to [.agents/standards/documentation-standards.md](.agents/standards/documentation-standards.md) and [.agents/standards/code-documentation-standards.md](.agents/standards/code-documentation-standards.md). Maintain clear documentation for targets, variables, and playbooks.
- **Memory Policy:** Refer to [.agents/standards/memory-policy.md](.agents/standards/memory-policy.md). Maintain `.agents/memory/PROJECT_CONTEXT.md` for durable facts and `.agents/memory/AI_HANDOFF.md` for active session state and tasks.
- **Questions Are Inquiries, Not Edits:** Answer questions and propose actions before making changes; do not execute edits on questions alone.
- **Strict Scope Control:** Do not refactor code or infrastructure definitions outside the defined scope of the instruction without explicit user permission.
- **Selective Verification:** When changes are strictly limited to comments or documentation, running validation checks is unnecessary.

---

## 5. Session Workflow

1. **Startup:** Read `.agents/memory/AI_HANDOFF.md` and `.agents/memory/PROJECT_CONTEXT.md` to restore context and understand active tasks.
2. **Execution:** Work on the next prioritized task. Ensure changes are formatted (`make fmt`) and validated (`make validate`).
3. **Completion & Handoff:** Run `/commit-cleanup` and `/handoff` to leave a clean state.
