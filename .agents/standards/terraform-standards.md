# Terraform Standards — RWD.Infrastructure

These standards govern all Terraform root environments and reusable modules under `iac/terraform/`.

---

## 1. Directory & Module Architecture

- **Environments (`iac/terraform/environments/`):** Isolated Terraform roots (`proxmox/<node>`, `github/<org>`, `infisical/`). Keep blast radius small per root module.
- **Modules (`iac/terraform/modules/`):** Reusable components grouped by provider (`proxmox/`, `github/`). Modules must not declare `provider` or `cloud` blocks—they inherit providers from the calling root environment.
- **Standard Module Layout:**
  ```text
  modules/<provider>/<module-name>/
  ├── README.md
  ├── main.tf
  ├── variables.tf
  └── outputs.tf
  ```
- **Naming:** Use `kebab-case` for module directory names (`clone-vm`, `github-repository`) and `snake_case` for resources, locals, variables, and outputs.

---

## 2. Execution & State Management Rules

- **Makefile-Only Execution:** Always run Terraform through the root `Makefile` (`make init`, `make plan`, `make apply`, `make validate`, `make fmt`, `make clean`, `make destroy` with `TARGET=<env-path>`, e.g., `TARGET=proxmox/pve-p01`). Never invoke raw `terraform` CLI commands from the repository root so `.env` and `TF_VAR_infisical_*` exports are consistently applied.
- **HCP Terraform Remote State:** Environments store state remotely in HCP Terraform (`realworlddevelopers` / `RWD Infrastructure`). Developers authenticate locally via `terraform login` (`~/.terraform.d/credentials.tfrc.json`). Never store the HCP Terraform user token in Infisical or git.
- **Secrets via Infisical:** Fetch provider tokens and infrastructure secrets via `data "infisical_secrets"` in `data.tf` and expose them via `locals.tf`. Never commit `.tfvars`, `.tfstate`, `tfplan`, or hardcoded credentials.

---

## 3. Variables, Outputs & Comments

- **Descriptions Required:** Every `variable` and `output` block must include a clear, accurate `description` attribute. Keep `[default is ...]` annotations (if included) strictly in sync with `default = ...`.
- **Sensitivity:** Mark secret inputs (`infisical_client_id`, `infisical_client_secret`, tokens, passwords) with `sensitive = true`. When passing Infisical-derived non-secret strings (such as usernames) into `toset()` or `for_each`, use `nonsensitive(...)` with an inline "why" comment.
- **Non-Obvious Logic:** Add concise "why" comments on `lifecycle { ignore_changes = [...] }`, `depends_on`, `trimspace(...)` drift workarounds, non-zero list indexing (e.g., `ipv4_addresses[1][0]` skipping loopback), and `insecure = true` TLS settings.
- **No Dead Code:** Do not leave commented-out `import {}` blocks, old version constraints, or unused variables in `.tf` files. (Exception: explicitly documented `unarchive` blocks where retained by owner decision.)

---

## 4. Verification & Zero-Drift Refactors

- Always run `make fmt TARGET=<env>` and `make validate TARGET=<env>` after modifying `.tf` files.
- Structural refactors (moving literals to `iac/shared/infrastructure.yml`, reorganizing locals/modules) must produce **No changes** on `make plan TARGET=<env>` for every affected environment.
- Keep module and environment `README.md` files synchronized with inputs, outputs, and examples (`.agents/templates/terraform-module-readme-template.md`).
