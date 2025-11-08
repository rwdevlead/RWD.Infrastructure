output "repository_id" {
  description = "The GitHub repository ID."
  value       = github_repository.this.node_id
}

output "repository_url" {
  description = "The HTML URL of the GitHub repository."
  value       = github_repository.this.html_url
}

output "repository_name" {
  description = "The HTML URL of the GitHub repository."
  value       = github_repository.this.name
}
