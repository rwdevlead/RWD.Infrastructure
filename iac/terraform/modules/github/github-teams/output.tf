output "team_slugs" {
  description = "Map of team slugs keyed by team name."
  value = {
    for k, v in github_team.this : k => v.slug
  }
}

output "team_ids" {
  description = "Map of team IDs keyed by team name."
  value       = { for k, v in github_team.this : k => v.id }
}
