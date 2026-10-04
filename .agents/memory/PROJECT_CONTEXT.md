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

## 4. Domain & Data Concepts
- **Targets:** Isolated deployment boundaries (e.g. `proxmox`, `github`).
- **Environments:** Deployment tiers (`dev`, `prod`).
- **Playbooks:** Idempotent service configurations applied to target inventory groups.

## 5. Constraints & Non-Goals
- **Hard Constraints:** All infrastructure definitions must be idempotent and non-destructive where possible.
- **Explicit Non-Goals:** Storing application-level source code; storing unencrypted private keys or state secrets in repository git history.

## 6. Architecture & Milestone Log
- `2026-09-30`: Initialized project AI operating surface (`.agents/`, `AGENTS.md`) using `RWD.Ai.Stack` framework.
- `2026-10-04`: Refreshed project AI guidance, aligned `AGENTS.md` build/run targets with `Makefile`, and normalized standard paths.
