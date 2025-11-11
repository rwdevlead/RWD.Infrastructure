````md
# terraform-github-classic-protection-module

This module adds a CODEOWNERS file (if missing) and applies _classic_ GitHub branch protection to a branch, with `enforce_admins` defaulting to `false` so repository admins can bypass the rules.

Usage example:

```hcl
module "repo_protect" {
  source = "./modules/github-classic-protection"

  repository = "org-name/repo-name"
  branch     = "main"

  # Provide CODEOWNERS content if you want the module to create it
  codeowners_content = <<-EOT
  # CODEOWNERS
  * @org/owners-team
  EOT

  # Keep enforce_admins = false so admins can bypass
  enforce_admins = false

  required_status_check_contexts = ["ci/test", "ci/lint"]
}
```
````

Notes:

- Manually ensure the GitHub provider is configured in the root module with credentials that have admin permissions for the repo.
- This module is intentionally simple and uses classic branch protection to allow admins (repo owners) to bypass protections.
