locals {
  repo_features = {
    has_issues      = true
    has_wiki        = false
    has_discussions = true
    has_projects    = false
    auto_init       = true
  }

  branch_protection_settings = {
    # Allow PAT/admin owner to bypass branch checks during automated repo management
    enforce_admins                  = false
    dismiss_stale_reviews           = true
    require_code_owner_reviews      = true
    required_approving_review_count = 1
  }

  managed_by = "Managed by Terraform"
}
