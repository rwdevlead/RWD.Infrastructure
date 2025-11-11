
# *** import repo ***
# import {
#   id = "RWD.Graphics"
#   to = module.rwd_graphics.github_repository.this
# }


# create a open repo
module "rwd_graphics" {
  source = "./modules/github-repository"

  providers = {
    github = github.primary
  }

  repository_name = "RWD.Graphics"
  description     = "Graphics for Real World Developers - ${local.managed_by}"
  visibility      = "private"

  topics          = ["images", "branding"]
  has_issues      = local.repo_features.has_issues
  has_projects    = local.repo_features.has_projects
  has_wiki        = local.repo_features.has_wiki
  auto_init       = local.repo_features.auto_init
  has_discussions = local.repo_features.has_discussions

}

# Use CODEOWNERS module to manage the CODEOWNERS file
module "codeowners_rwd_graphics" {
  source = "./modules/github-codeowners"
  providers = {
    github = github.primary
  }

  repository   = module.rwd_graphics.repository_name
  branch       = "main"
  github_owner = var.github_owner_primary
  # admins       = [var.github_owner_primary]
  owners = [var.github_owner_primary]

  depends_on = [module.rwd_graphics]

  # extra_rules = {
  #   "/frontend/*" = "dave"
  #   "/backend/*"  = "eve"
  # }

}

# create classic branch protection instead of a ruleset
# module "branch_protection_rwd_graphics" {
#   source = "./modules/github-branch-protection"
#   providers = {
#     github = github.primary
#   }

#   repository_id = module.rwd_graphics.repository_id
#   branch        = "main"

#   github_owner = var.github_owner_primary
#   # codeowners_admins = [var.github_owner_primary]
#   # codeowners_owners = [var.github_owner_primary]

#   # Branch protection settings
#   enforce_admins = local.branch_protection_settings.enforce_admins
#   # //// strict_required_status_checks   = local.branch_protection_settings.strict_required_status_checks
#   # //// required_status_check_contexts  = local.branch_protection_settings.required_status_check_contexts
#   # //dismiss_stale_reviews           = local.branch_protection_settings.dismiss_stale_reviews
#   require_code_owner_reviews      = local.branch_protection_settings.require_code_owner_reviews
#   required_approving_review_count = local.branch_protection_settings.required_approving_review_count

#   depends_on = [module.codeowners_rwd_graphics]

# }


