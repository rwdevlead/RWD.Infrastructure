
# *** import repo ***
# import {
#   id = "RWD.Toolbox.Ui.Middleware"
#   to = module.rwd_toolbox_ui_middleware.github_repository.this
# }

# import {
#   id = "RWD.Toolbox.Ui.Middleware:master"
#   to = module.branch_protection_rwd_toolbox_ui_middleware.github_branch_protection.branch
# }

# import {
#   id = "RWD.Toolbox.Ui.Middleware/.github/CODEOWNERS"
#   to = module.codeowners_rwd_toolbox_ui_middleware.github_repository_file.codeowners
# }

# create a open repo
module "rwd_toolbox_ui_middleware" {
  source = "../../../modules/github/github-repository"

  repository_name = "RWD.Toolbox.Ui.Middleware"
  description     = ".NET Core Tool for adding CSP and other Security HTTP Headers - ${local.managed_by}"
  visibility      = "public"

  topics          = ["aspnetcore", "csharp", "net6", "nuget", "shared"]
  has_issues      = local.repo_features.has_issues
  has_projects    = local.repo_features.has_projects
  has_wiki        = local.repo_features.has_wiki
  auto_init       = local.repo_features.auto_init
  has_discussions = local.repo_features.has_discussions

}

# Use CODEOWNERS module to manage the CODEOWNERS file
module "codeowners_rwd_toolbox_ui_middleware" {
  source = "../../../modules/github/github-codeowners"

  repository   = module.rwd_toolbox_ui_middleware.repository_name
  branch       = "master"
  github_owner = var.github_owner_realworlddevelopers
  # admins       = [var.github_owner_secondary]
  owners = [var.github_owner_realworlddevelopers]

  depends_on = [module.rwd_toolbox_ui_middleware]

}

# create classic branch protection instead of a ruleset
module "branch_protection_rwd_toolbox_ui_middleware" {
  source = "../../../modules/github/github-branch-protection"

  repository_id = module.rwd_toolbox_ui_middleware.repository_id
  branch        = "master"

  github_owner = var.github_owner_realworlddevelopers
  # codeowners_admins = [var.github_owner_secondary]
  # codeowners_owners = [var.github_owner_secondary]

  # Branch protection settings
  enforce_admins = local.branch_protection_settings.enforce_admins
  # //// strict_required_status_checks   = local.branch_protection_settings.strict_required_status_checks
  # //// required_status_check_contexts  = local.branch_protection_settings.required_status_check_contexts
  # //dismiss_stale_reviews           = local.branch_protection_settings.dismiss_stale_reviews
  require_code_owner_reviews      = local.branch_protection_settings.require_code_owner_reviews
  required_approving_review_count = local.branch_protection_settings.required_approving_review_count

  depends_on = [module.codeowners_rwd_toolbox_ui_middleware]

}


