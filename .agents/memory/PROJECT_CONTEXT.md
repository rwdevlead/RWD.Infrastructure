# PROJECT_CONTEXT.md — Long-Term Project Context

## 1. Project Overview
- **Project Name:** RWD.Infrastructure
- **Purpose:** Infrastructure as Code (IaC) repository automating the provisioning, configuration, and orchestration of Real World Developers infrastructure resources.
- **Primary Goals:** Declarative, repeatable deployments of VMs, networks, storage, container runtimes, and self-hosted internal services.

## 2. Technical Stack & Dependencies
- **Core Languages & Frameworks:** HCL (Terraform), YAML (Ansible), GNU Make, Bash.
- **Infrastructure Providers:** Proxmox VE, TrueNAS, Traefik, Docker / Portainer, Pi-hole.
- **Secrets & Variable Management:** Infisical, `.env` file overrides.

## 3. Architecture & Core Patterns
- **Architecture Pattern:** Multi-root IaC structure with independent Terraform environment targets under `iac/terraform/environments/` and shared reusable modules under `iac/terraform/modules/`.
- **Configuration Management:** Ansible playbooks and modular roles under `iac/ansible/` executed post-provisioning.
- **Orchestration Pattern:** Root `Makefile` acts as the single interface for multi-tool operations, handling environment injection, target resolution, and validation.
- **Canonical Design Decisions:**
  - Independent root modules for each Terraform target to limit blast radius.
  - Zero hardcoded credentials in version control; secrets supplied via Infisical / environment variables.
  - Terraform operations must exclusively be executed via `Makefile` commands (`make init`, `make plan`, `make apply`, `make validate`, `make fmt`), never through raw `terraform` CLI invocations.
  - HCP Terraform State Authentication vs Infisical: Remote state connections to HCP Terraform (Terraform Cloud) require a user API token acquired locally via `terraform login` (stored in `~/.terraform.d/credentials.tfrc.json`). This HCP state connection token is NOT stored in Infisical. Infisical manages all other infrastructure variables and secrets (GitHub tokens, Proxmox credentials, API tokens, SSH keys, etc.).
  - Home Assistant Module Architecture: The current `homeassistant` module embeds local image uploading (`haos_ova-16.3.img`). When refactoring for multi-VM instantiation in the future, decouple image management by parameterizing `image_file_id` (pointing to `local:iso/haos_ova-16.3.img` on Proxmox) or using `proxmox_virtual_environment_download_file` to prevent local file dependencies and datastore name collisions.

## 4. Domain & Data Concepts
- **Targets:** Isolated deployment boundaries (e.g. `proxmox`, `github`).
- **Environments:** Deployment tiers (`dev`, `prod`).
- **Playbooks:** Idempotent service configurations applied to target inventory groups.

## 5. Constraints & Non-Goals
- **Hard Constraints:** 
  - All infrastructure definitions must be idempotent and non-destructive where possible.
  - Always invoke Terraform through `Makefile` targets (`make <target> TARGET=<env-path>`), ensuring environment variables and Infisical configurations are properly set.
  - No Guessing Policy: AI agents must never guess or make assumptions about infrastructure configuration, variable values, secret mappings, or code behavior. Always research the codebase and documentation thoroughly to find the verified answer, or ask the user directly for clarification.
- **Explicit Non-Goals:** Storing application-level source code; storing unencrypted private keys or state secrets in repository git history.

## 6. Architecture & Milestone Log
- `2026-09-30`: Initialized project AI operating surface (`.agents/`, `AGENTS.md`) using `RWD.Ai.Stack` framework.
- `2026-10-04`: Refreshed project AI guidance, aligned `AGENTS.md` build/run targets with `Makefile`, and normalized standard paths.
- `2026-11-02`: Added required `vm_on_boot` attribute to `clone-vm`, `truenas-vm`, `homeassistant`, and `omv-vm` modules (set to `false` across environments), fixed HA image replacement drift, codified Makefile-only execution policy for all Terraform operations, documented future HA multi-instance refactoring strategy, and completed comprehensive documentation sync across all `iac/terraform/` modules and environments (Proxmox, GitHub, Infisical).
- `2026-11-03`: Enabled QEMU guest agent in `omv-vm` module, added module outputs (`vm_ipv4_address`, `vm_id`), and updated documentation.
- `2026-11-16`: Added `proxmox/nut` Ansible role, `proxmox_cluster` inventory/group_vars (`nut_instances`), and `playbooks/nut.yml` for dynamic cluster-wide UPS monitoring and tiered VM/host shutdown and bring-up orchestration; removed secret-printing debug task from `infisical_secrets`.
- `2026-11-16`: Added `iac/shared/infrastructure.yml` as the single source of truth for network, Proxmox node, and VM topology across Terraform (`yamldecode(file(...))`) and Ansible (`inventories/group_vars/all.yml`), refactored all Proxmox Terraform environments and Ansible inventories/group_vars/playbooks/roles/templates onto shared variables, and removed redundant `host_vars/*.yml`, obsolete `truenas/nfs` role/playbook, and dead `Makefile` storage targets.
- `2026-11-16`: Moved Uptime Kuma Nebula push token (`/ansible/uptime_kuma` → `NEBULA_PUSH_TOKEN`) and Traefik ACME email (`/ansible/cloudflare` → `ACME_EMAIL`) to Infisical, removed unused `apps/semaphore` role, and converted `iac/ansible/ansible.cfg` to portable relative paths (`export ANSIBLE_CONFIG` in `Makefile`).
- `2026-11-17`: Completed full Ansible documentation sync (`iac/ansible/README.md`, `inventories/README.md`, `playbooks/README.md`, `roles/README.md`, and all category/role READMEs; removed stale `DNS_CHECK_LIST.md`), updated root `README.md` and `AGENTS.md` to reflect the current `Makefile`, `iac/shared/infrastructure.yml`, Terraform, and Ansible workflows, and aligned inline code comments, Terraform variable/output descriptions, and `.env.example` with code documentation standards.
- `2026-11-17`: Consolidated `.github/instructions` and `.github/copilot-instructions.md` into `.agents/` (added `ansible-standards.md`, `terraform-standards.md`, `shared-config-standards.md`, Ansible/Terraform README & skeleton templates, and `/new-ansible-role`, `/new-terraform-module`, `/add-infra-host`, `/secrets-audit` skills) and removed legacy `.github` instruction files while keeping `.github/pull_request_template.md`.
- `2026-11-17`: Added `diff: false` for NUT credential templates (`upsmon.conf`, `upsd.users`), fixed `staged_takedown.sh.j2` shebang placement, `docker/engine` handler mismatch and unused defaults, `clone-vm` variable wiring with `sensitive = true` on `vm_password`/`default_password`, and `rwd-numpicker.tf` `codeowners` branch mismatch; removed `TEST_VAR`, unused `github-repository` team variables, unused Traefik `default-whitelist`/`secured` middlewares, empty `scripts/`, and `.DS_Store` files.
