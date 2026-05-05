variable "github_owner" {
  description = "The GitHub organization or user that owns the teams."
  type        = string
}

variable "teams" {
  description = <<-EOT
    Map of team definitions. Each key is the team name, and the value is an object containing:
      - description: team description
      - members: list of GitHub usernames
  EOT

  type = map(object({
    description = string
    members     = list(string)
  }))
}
