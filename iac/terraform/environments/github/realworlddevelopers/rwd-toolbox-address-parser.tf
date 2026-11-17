module "rwd_toolbox_address_parser" {
  source = "../../../modules/github/github-repository"

  repository_name = "RWD.Toolbox.AddressParser"
  description     = "A String Parsing and Transformation Tool for Postal Addresses - ${local.managed_by}"
  visibility      = "public"

  topics          = ["csharp", "net6", "nuget", "shared"]
  has_issues      = local.repo_features.has_issues
  has_projects    = local.repo_features.has_projects
  has_wiki        = local.repo_features.has_wiki
  auto_init       = local.repo_features.auto_init
  has_discussions = local.repo_features.has_discussions
}

module "codeowners_rwd_toolbox_address_parser" {
  source = "../../../modules/github/github-codeowners"

  repository   = module.rwd_toolbox_address_parser.repository_name
  branch       = "master"
  github_owner = local.github_owner
  owners       = [local.github_owner]

  # Ensure the repository and initial branch exist before committing .github/CODEOWNERS
  depends_on = [module.rwd_toolbox_address_parser]
}

module "branch_protection_rwd_toolbox_address_parser" {
  source = "../../../modules/github/github-branch-protection"

  repository_id = module.rwd_toolbox_address_parser.repository_id
  branch        = "master"

  github_owner = local.github_owner

  enforce_admins                  = local.branch_protection_settings.enforce_admins
  require_code_owner_reviews      = local.branch_protection_settings.require_code_owner_reviews
  required_approving_review_count = local.branch_protection_settings.required_approving_review_count

  # Require CODEOWNERS file before enabling require_code_owner_reviews on the branch
  depends_on = [module.codeowners_rwd_toolbox_address_parser]
}
