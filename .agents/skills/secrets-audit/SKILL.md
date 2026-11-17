---
name: secrets-audit
description: Scan the repository for hardcoded secrets, PII, unsafe secret logging, or stale .env references and map findings to Infisical. Trigger with "/secrets-audit".
argument-hint: "[optional path scope, defaults to iac/]"
---

# Purpose

Audit Terraform, Ansible, and root configuration files for values that belong in Infisical, unsafe `--diff` / console exposure, or stale secret patterns.

---

## Step 1 — Scan Target Scope

Read `.agents/standards/shared-config-standards.md`, `.agents/standards/ansible-standards.md`, and `.agents/standards/terraform-standards.md`.

Inspect the target scope (default: `iac/`, `.env.example`, `Makefile`, root scripts) for:
1. Hardcoded passwords, API tokens, private keys, webhook URLs containing tokens, or personal/PII email addresses.
2. Ansible tasks that print `secrets` / `read_results` or template credential files without `no_log: true` / `diff: false`.
3. Terraform variables holding credentials without `sensitive = true`, or stale `ansible-vault` / `.env` references where Infisical is expected.
4. Untracked or unignored temporary files (`*.diff`, `*.tfstate`, `.env`, `*.retry`) that may contain plaintext secrets.

---

## Step 2 — Classify & Propose Remediations

Present a structured report distinguishing:
- **Keep in code:** Non-secret IPs, subnets, VM IDs, disk IDs, public domains, and `.env.example` placeholders.
- **Move to Infisical:** Recommend exact Infisical path (`/ansible/<role>` or `/terraform/...`) and key names, plus `infisical_secret_paths` / `data.infisical_secrets` wiring.
- **Mask/Harden:** Missing `no_log: true`, `diff: false`, or `sensitive = true`.

Wait for user approval before editing files or asking the user to populate Infisical keys (AI agents cannot write secrets into Infisical directly).

---

## Step 3 — Verify Clean State

After approved fixes:
1. Confirm `make test-infisical` and relevant `make <target>-check` or `make plan TARGET=<env>` pass with zero unexpected drift and zero secret leakage in console diffs.
2. Remind the user to rotate any previously exposed credentials in Infisical.
