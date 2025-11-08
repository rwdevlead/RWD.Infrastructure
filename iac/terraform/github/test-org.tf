
# module "codeowners_test_org" {
#   source = "./modules/github-codeowners"

#   github_owner = var.github_owner_secondary

#   providers = {
#     github = github.organization
#   }
#   repository = module.test_open_repo_on_org.repository_name

#   admins = [var.github_owner_primary]
#   owners = [var.github_owner_primary]

#   # extra_rules = {
#   #   "/frontend/*" = "dave"
#   #   "/backend/*"  = "eve"
#   # }

# }

# # Use CODEOWNERS module to manage the CODEOWNERS file
# module "codeowners" {
#   source = "./modules/github-codeowners"
#   providers = {
#     github = github.primary
#   }

#   repository   = module.test_open_repo_on_primary.repository_name
#   github_owner = var.github_owner_primary
#   admins       = [var.github_owner_primary]
#   owners       = [var.github_owner_primary]

#   depends_on = [module.test_open_repo_on_primary]
# }

# # create classic branch protection instead of a ruleset
# module "branch_protection_main" {
#   source = "./modules/github-branch-protection" # path to the module
#   providers = {
#     github = github.primary
#   }

#   # repository    = module.test_open_repo_on_primary.repository_name
#   repository_id = module.test_open_repo_on_primary.repository_id
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

#   depends_on = [module.codeowners]

# }
