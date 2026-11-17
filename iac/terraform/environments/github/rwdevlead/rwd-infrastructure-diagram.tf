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

module "codeowners_rwd_infrastructure_diagram" {
  source = "../../../modules/github/github-codeowners"

  repository   = module.rwd_infrastructure_diagram.repository_name
  branch       = "main"
  github_owner = local.github_owner
  owners       = [local.github_owner]

  # Ensure the repository and initial branch exist before committing .github/CODEOWNERS
  depends_on = [module.rwd_infrastructure_diagram]
}

module "branch_protection_rwd_infrastructure_diagram" {
  source = "../../../modules/github/github-branch-protection"

  repository_id = module.rwd_infrastructure_diagram.repository_id
  branch        = "main"

  github_owner = local.github_owner

  enforce_admins                  = local.branch_protection_settings.enforce_admins
  require_code_owner_reviews      = local.branch_protection_settings.require_code_owner_reviews
  required_approving_review_count = local.branch_protection_settings.required_approving_review_count

  # Require CODEOWNERS file before enabling require_code_owner_reviews on the branch
  depends_on = [module.codeowners_rwd_infrastructure_diagram]
}
