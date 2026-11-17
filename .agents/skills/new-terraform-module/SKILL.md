---
name: new-terraform-module
description: Scaffold a new reusable Terraform module under iac/terraform/modules/ with README and standard HCL structure. Trigger with "/new-terraform-module".
argument-hint: "<provider>/<module-name> (e.g. proxmox/lxc-container)"
---

# Purpose

Create a reusable Terraform module under `iac/terraform/modules/<provider>/<module-name>/` following `.agents/standards/terraform-standards.md`.

---

## Step 1 — Gather & Validate Inputs

1. Read `.agents/standards/terraform-standards.md` and `.agents/standards/shared-config-standards.md`.
2. Confirm the provider category (`proxmox` or `github`), `kebab-case` module name, required inputs, outputs, and any lifecycle/provider constraints.
3. Propose the file plan and wait for user approval before editing.

---

## Step 2 — Scaffold Module Files

Create `iac/terraform/modules/<provider>/<module-name>/`:

1. `main.tf` — Declare `required_providers` without `provider` or `cloud` blocks; add inline "why" comments on `lifecycle { ignore_changes }`, `depends_on`, or provider workarounds.
2. `variables.tf` — Add a clear `description` to every variable, mark secrets `sensitive = true`, and avoid hardcoded environment IPs/IDs.
3. `outputs.tf` — Add a `description` to every output and explain any non-obvious indexing (such as `ipv4_addresses[1][0]`).
4. `README.md` — Follow `.agents/templates/terraform-module-readme-template.md` with features, usage example, inputs table, outputs table, and notes.

---

## Step 3 — Update Index & Validate

1. Add the module to `iac/terraform/modules/README.md`, `iac/terraform/modules/<provider>/README.md`, and `iac/terraform/README.md`.
2. Run formatting and validation via `Makefile` targets (`make fmt TARGET=<env>` and `make validate TARGET=<env>` for any calling environment) and confirm clean `make plan TARGET=<env>`.
