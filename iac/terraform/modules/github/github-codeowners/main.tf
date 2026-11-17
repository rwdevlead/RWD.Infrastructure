locals {
  base_content = join("\n", [
    "# CODEOWNERS",
    "# Automatically managed by Terraform.",
    "# Global owners",
    join("\n", [for u in var.admins : "* @${u}"]),
    join("\n", [for u in var.owners : "* @${u}"])
  ])

  extra_content = length(var.extra_rules) > 0 ? join("\n", [
    "",
    "# Additional ownership rules",
    join("\n", [
      for path, owner in var.extra_rules : "${path} @${owner}"
    ])
  ]) : ""

  codeowners_content = trimspace("${local.base_content}${local.extra_content}")

  # Strip Infisical sensitivity so toset() can iterate owner usernames in data.github_user.owners for_each
  all_owners = nonsensitive(distinct(concat(
    var.admins,
    var.owners,
    [for _, owner in var.extra_rules : owner]
  )))
}

# Look up numeric IDs for all owners to enable ruleset bypass
data "github_user" "owners" {
  for_each = toset(local.all_owners)
  username = each.key
}

resource "github_repository_file" "codeowners" {
  repository          = var.repository
  branch              = var.branch
  file                = ".github/CODEOWNERS"
  content             = local.codeowners_content
  commit_message      = "Add or update CODEOWNERS file"
  overwrite_on_create = true
}
