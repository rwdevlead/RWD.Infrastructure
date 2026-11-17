resource "github_branch_protection" "branch" {
  repository_id = var.repository_id
  pattern       = var.branch

  # Allow repository administrators (PAT owner) to bypass branch rules for automated maintenance
  enforce_admins = var.enforce_admins

  required_status_checks {
    strict   = var.strict_required_status_checks
    contexts = var.required_status_check_contexts
  }

  required_pull_request_reviews {
    dismiss_stale_reviews           = var.dismiss_stale_reviews
    require_code_owner_reviews      = var.require_code_owner_reviews
    required_approving_review_count = var.required_approving_review_count
  }
}
