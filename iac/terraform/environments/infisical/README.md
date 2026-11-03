# Infisical Testing Environment - Terraform

This directory contains the Terraform configuration for testing and validating the Infisical secret management integration.

## Environment Overview

- **Target:** `infisical`
- **HCP Terraform Workspace:** `infisical-testing` (Project: `RWD Infrastructure`, Org: `realworlddevelopers`)
- **Provider:** `Infisical/infisical` (~> 0.14)
- **Purpose:** Test and validate Infisical vault authentication, secret retrieval via data sources, and test `.env` file generation.

## Key Logic

The module connects to the Infisical API using Universal Auth credentials and retrieves secrets from the `/terraform/github` folder in the `dev` environment:

```hcl
data "infisical_secrets" "github" {
  env_slug     = "dev"
  folder_path  = "/terraform/github"
  workspace_id = var.infisical_project_id
}
```

It renders a local `.env.test` file (gitignored) containing the retrieved variables for verification:

```hcl
resource "local_file" "test_env" {
  filename = "${path.module}/.env.test"
  content  = <<-EOT
    TF_VAR_github_owner_rwdevlead=${data.infisical_secrets.github.secrets["TF_VAR_github_owner_rwdevlead"].value}
  EOT
}
```

## Inputs

| Name                      | Description                                   | Type     | Sensitive | Required |
| ------------------------- | --------------------------------------------- | -------- | --------- | -------- |
| `infisical_client_id`     | Infisical Machine Identity Client ID          | `string` | yes       | yes      |
| `infisical_client_secret` | Infisical Machine Identity Client Secret      | `string` | yes       | yes      |
| `infisical_project_id`    | Infisical Project / Workspace ID              | `string` | no        | yes      |

Inputs are automatically mapped from the repository `.env` file to `TF_VAR_*` environment variables by the root `Makefile`.

## Outputs

| Name                | Description                                       | Sensitive |
| ------------------- | ------------------------------------------------- | --------- |
| `mail_user_preview` | Preview of the retrieved secret value from vault | yes       |

## Prerequisites & HCP Terraform Authentication

1. **HCP Terraform Token**
   - Run `terraform login` to authenticate with HCP Terraform (`app.terraform.io`). The token is saved in `~/.terraform.d/credentials.tfrc.json`.
   - **Important:** **The Terraform Cloud user API token is NOT stored in Infisical.** It must be generated and managed directly on your local workstation via `terraform login`.
2. **Infisical Universal Auth Credentials**
   - Configured in `.env` (`INFISICAL_CLIENT_ID`, `INFISICAL_CLIENT_SECRET`, `INFISICAL_PROJECT_ID`).

## Working with This Environment

All operations should be executed via the repository root Makefile:

### Initialize

```bash
make init TARGET=infisical
```

### Plan Changes

```bash
make plan TARGET=infisical
```

### Apply Configuration

```bash
make apply TARGET=infisical
```

## Important Notes

- **Secrets Handling:** The client ID, secret, and output values are marked sensitive to prevent leaking credentials into Terraform logs and state.
- **Generated Files:** `.env.test` is generated locally for validation and is excluded from git version control.
