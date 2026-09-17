# *** import repo ***
# import {
#   id = "RWD.Poker.Clock"
#   to = module.rwd_poker_clock.github_repository.this
# }

# import {
#   id = "RWD.Poker.Clock:main"
#   to = module.branch_protection_rwd_poker_clock.github_branch_protection.branch
# }

# create a open repo
module "rwd_poker_clock" {
  source = "../../../modules/github/github-repository"

  repository_name = "RWD.Poker.Clock"
  description     = "Poker clock application - ${local.managed_by}"
  visibility      = "public"

  topics          = ["app"]
  has_issues      = local.repo_features.has_issues
  has_projects    = local.repo_features.has_projects
  has_wiki        = local.repo_features.has_wiki
  auto_init       = local.repo_features.auto_init
  has_discussions = local.repo_features.has_discussions

}

# Use CODEOWNERS module to manage the CODEOWNERS file
module "codeowners_rwd_poker_clock" {
  source = "../../../modules/github/github-codeowners"

  repository   = module.rwd_poker_clock.repository_name
  branch       = "main"
  github_owner = local.github_owner
  # admins       = [var.github_owner_primary]
  owners = [local.github_owner]

  depends_on = [module.rwd_poker_clock]

}

# create classic branch protection instead of a ruleset
module "branch_protection_rwd_poker_clock" {
  source = "../../../modules/github/github-branch-protection"

  repository_id = module.rwd_poker_clock.repository_id
  branch        = "main"

  github_owner = local.github_owner
  # codeowners_admins = [var.github_owner_primary]
  # codeowners_owners = [var.github_owner_primary]

  # Branch protection settings
  enforce_admins = local.branch_protection_settings.enforce_admins
  # //// strict_required_status_checks   = local.branch_protection_settings.strict_required_status_checks
  # //// required_status_check_contexts  = local.branch_protection_settings.required_status_check_contexts
  # //dismiss_stale_reviews           = local.branch_protection_settings.dismiss_stale_reviews
  require_code_owner_reviews      = local.branch_protection_settings.require_code_owner_reviews
  required_approving_review_count = local.branch_protection_settings.required_approving_review_count

  depends_on = [module.codeowners_rwd_poker_clock]

}
