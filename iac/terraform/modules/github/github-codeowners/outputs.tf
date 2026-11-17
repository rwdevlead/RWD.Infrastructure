output "codeowners_content" {
  description = "Rendered CODEOWNERS content."
  value       = local.codeowners_content
}

output "owner_ids" {
  description = "Map of all CODEOWNERS user IDs keyed by username"
  value       = { for name, user in data.github_user.owners : name => user.id }
}
