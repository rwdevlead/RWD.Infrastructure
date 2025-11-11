
# *** import repo ***
# import {
#   id = "RWD.Toolbox.Logging"
#   to = module.rwd_toolbox_logging.github_repository.this
# }

# create a open repo
module "rwd_toolbox_logging" {
  source = "./modules/github-repository"

  providers = {
    github = github.organization
  }

  repository_name = "RWD.Toolbox.Logging"
  description     = "Using Serilog within .NET Projects - ${local.managed_by}"
  visibility      = "public"

  topics          = ["webapi", "aspnetcore", "csharp", "net6", "nuget", "shared"]
  has_issues      = local.repo_features.has_issues
  has_projects    = local.repo_features.has_projects
  has_wiki        = local.repo_features.has_wiki
  auto_init       = local.repo_features.auto_init
  has_discussions = local.repo_features.has_discussions

}

# Use CODEOWNERS module to manage the CODEOWNERS file
module "codeowners_rwd_toolbox_logging" {
  source = "./modules/github-codeowners"
  providers = {
    github = github.organization
  }

  repository   = module.rwd_toolbox_logging.repository_name
  branch       = "master"
  github_owner = var.github_owner_secondary
  # admins       = [var.github_owner_secondary]
  owners = [var.github_owner_secondary]

  depends_on = [module.rwd_toolbox_logging]

  # extra_rules = {
  #   "/frontend/*" = "dave"
  #   "/backend/*"  = "eve"
  # }

}

# create classic branch protection instead of a ruleset
module "branch_protection_rwd_toolbox_logging" {
  source = "./modules/github-branch-protection"
  providers = {
    github = github.organization
  }

  repository_id = module.rwd_toolbox_logging.repository_id
  branch        = "master"

  github_owner = var.github_owner_secondary
  # codeowners_admins = [var.github_owner_secondary]
  # codeowners_owners = [var.github_owner_secondary]

  # Branch protection settings
  enforce_admins = local.branch_protection_settings.enforce_admins
  # //// strict_required_status_checks   = local.branch_protection_settings.strict_required_status_checks
  # //// required_status_check_contexts  = local.branch_protection_settings.required_status_check_contexts
  # //dismiss_stale_reviews           = local.branch_protection_settings.dismiss_stale_reviews
  require_code_owner_reviews      = local.branch_protection_settings.require_code_owner_reviews
  required_approving_review_count = local.branch_protection_settings.required_approving_review_count

  depends_on = [module.codeowners_rwd_toolbox_logging]

}


