
resource "github_repository" "this" {
  name                   = var.repository_name
  description            = var.description
  visibility             = var.visibility
  topics                 = var.topics
  has_issues             = var.has_issues
  has_projects           = var.has_projects
  has_wiki               = var.has_wiki
  auto_init              = var.auto_init
  has_discussions        = var.has_discussions
  delete_branch_on_merge = true
  vulnerability_alerts   = true
  archive_on_destroy     = false
}




