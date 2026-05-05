
# *** import repo ***
# import {
#   id = "RWD.Graphics"
#   to = module.rwd_graphics.github_repository.this
# }


# create a open repo
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

# Use CODEOWNERS module to manage the CODEOWNERS file
module "codeowners_rwd_graphics" {
  source = "../../../modules/github/github-codeowners"

  repository   = module.rwd_graphics.repository_name
  branch       = "main"
  github_owner = var.github_owner_rwdevlead
  # admins       = [var.github_owner_primary]
  owners = [var.github_owner_rwdevlead]

  depends_on = [module.rwd_graphics]

}

