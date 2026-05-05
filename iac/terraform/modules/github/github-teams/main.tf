resource "github_team" "this" {
  for_each    = var.teams
  name        = each.key
  description = each.value.description
}
resource "github_team_membership" "this" {
  for_each = merge([
    for team_name, team in var.teams : {
      for member in team.members :
      "${team_name}-${member}" => {
        team_name = team_name
        username  = member
      }
    }
  ]...)

  team_id  = github_team.this[each.value.team_name].id
  username = each.value.username
  role     = "member"
}
