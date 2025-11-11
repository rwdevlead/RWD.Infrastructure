# output "codeowners_module_id" {
#   description = "ID of the CODEOWNERS module used"
#   value       = module.codeowners.id
# }

output "branch_protection_id" {
  description = "ID of the branch protection resource"
  value       = github_branch_protection.branch.id
}
