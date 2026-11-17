module "rwd_graphics" {
  source = "../../../modules/github/github-repository"

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

module "codeowners_rwd_graphics" {
  source = "../../../modules/github/github-codeowners"

  repository   = module.rwd_graphics.repository_name
  branch       = "main"
  github_owner = local.github_owner
  owners       = [local.github_owner]

  # Ensure the repository and initial branch exist before committing .github/CODEOWNERS
  depends_on = [module.rwd_graphics]
}
