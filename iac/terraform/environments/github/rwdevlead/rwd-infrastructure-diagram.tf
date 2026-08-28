
# *** import repo ***
# import {
#   id = "RWD.Infrastructure.Diagram"
#   to = module.rwd_infrastructure_diagram.github_repository.this
# }

# import {
#   id = "RWD.Infrastructure.Diagram:main"
#   to = module.branch_protection_rwd_infrastructure_diagram.github_branch_protection.branch
# }

# create a open repo
module "rwd_infrastructure_diagram" {
  source = "../../../modules/github/github-repository"

  repository_name = "RWD.Infrastructure.Diagram"
  description     = "Network Utility for Infrastructure - ${local.managed_by}"
  visibility      = "public"

  topics          = ["dotnet", "reactjs", "vite", "utility", "sqlite"]
  has_issues      = local.repo_features.has_issues
  has_projects    = local.repo_features.has_projects
  has_wiki        = local.repo_features.has_wiki
  auto_init       = local.repo_features.auto_init
  has_discussions = local.repo_features.has_discussions

}

# Use CODEOWNERS module to manage the CODEOWNERS file
module "codeowners_rwd_infrastructure_diagram" {
  source = "../../../modules/github/github-codeowners"

  repository   = module.rwd_infrastructure_diagram.repository_name
  branch       = "main"
  github_owner = local.github_owner
  # admins       = [var.github_owner_primary]
  owners = [local.github_owner]

  depends_on = [module.rwd_infrastructure_diagram]

}

# create classic branch protection instead of a ruleset
module "branch_protection_rwd_infrastructure_diagram" {
  source = "../../../modules/github/github-branch-protection"

  repository_id = module.rwd_infrastructure_diagram.repository_id
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

  depends_on = [module.codeowners_rwd_infrastructure_diagram]

}


