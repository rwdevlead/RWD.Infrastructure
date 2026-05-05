locals {
  # Common repository features
  repo_features = {
    has_issues      = true
    has_wiki        = false
    has_discussions = true
    has_projects    = false
    auto_init       = true
  }

  # Branch protection settings
  branch_protection_settings = {
    enforce_admins = false # admins (PAT) can bypass
    // strict_required_status_checks   = true
    // required_status_check_contexts  = ["build", "test", "lint"]
    dismiss_stale_reviews           = true
    require_code_owner_reviews      = true
    required_approving_review_count = 1
  }

  # Managed by information
  managed_by = "Managed by Terraform"
}

