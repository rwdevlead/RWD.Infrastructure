
# *** import repo ***
# import {
#   id = "NumPicker"
#   to = module.rwd_numpicker.github_repository.this
# }

# create a open repo
module "rwd_numpicker" {
  source = "./modules/github-repository"

  providers = {
    github = github.primary
  }

  repository_name = "NumPicker"
  description     = "Just a fun lottery number picker - ${local.managed_by}"
  visibility      = "public"

  topics          = ["mvc", "frontend"]
  has_issues      = local.repo_features.has_issues
  has_projects    = local.repo_features.has_projects
  has_wiki        = local.repo_features.has_wiki
  auto_init       = local.repo_features.auto_init
  has_discussions = local.repo_features.has_discussions

}

# Use CODEOWNERS module to manage the CODEOWNERS file
module "codeowners_numpicker" {
  source = "./modules/github-codeowners"
  providers = {
    github = github.primary
  }

  repository   = module.rwd_numpicker.repository_name
  branch       = "master"
  github_owner = var.github_owner_primary
  # admins       = [var.github_owner_primary]
  owners = [var.github_owner_primary]

  depends_on = [module.rwd_numpicker]

  # extra_rules = {
  #   "/frontend/*" = "dave"
  #   "/backend/*"  = "eve"
  # }

}

# create classic branch protection instead of a ruleset
module "branch_protection_numpicker" {
  source = "./modules/github-branch-protection"
  providers = {
    github = github.primary
  }

  repository_id = module.rwd_numpicker.repository_id
  branch        = "main"

  github_owner = var.github_owner_primary
  # codeowners_admins = [var.github_owner_primary]
  # codeowners_owners = [var.github_owner_primary]

  # Branch protection settings
  enforce_admins = local.branch_protection_settings.enforce_admins
  # //// strict_required_status_checks   = local.branch_protection_settings.strict_required_status_checks
  # //// required_status_check_contexts  = local.branch_protection_settings.required_status_check_contexts
  # //dismiss_stale_reviews           = local.branch_protection_settings.dismiss_stale_reviews
  require_code_owner_reviews      = local.branch_protection_settings.require_code_owner_reviews
  required_approving_review_count = local.branch_protection_settings.required_approving_review_count

  depends_on = [module.codeowners_numpicker]

}


