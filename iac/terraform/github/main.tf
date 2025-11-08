locals {
  # Common repository features
  repo_features = {
    has_issues      = true
    has_wiki        = false
    has_discussions = true
    has_projects    = true
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



# *** import repo ***
# import {
#   id = "TEST.importme"
#   to = module.my_repo.github_repository.this
# }

module "my_repo" {
  source = "./modules/github-repository"

  providers = {
    github = github.primary
  }

  repository_name = "TEST.importme"
  description     = "Testing Terraform Import - ${local.managed_by}"
  visibility      = "public"

  topics          = ["terraform", "iac", "testing"]
  has_issues      = local.repo_features.has_issues
  has_projects    = local.repo_features.has_projects
  has_wiki        = local.repo_features.has_wiki
  auto_init       = local.repo_features.auto_init
  has_discussions = local.repo_features.has_discussions

}




