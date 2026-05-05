
variable "repository_id" {
  description = "Repository Id"
  type        = string
}

variable "branch" {
  description = "Branch name pattern to protect (default: main)"
  type        = string
  default     = "main"
}

variable "github_owner" {
  description = "Owner of the GitHub repository"
  type        = string
}


variable "enforce_admins" {
  description = "Whether to enforce branch protection for admins. Set false to let admins bypass."
  type        = bool
  default     = false
}

variable "strict_required_status_checks" {
  description = "Whether to enable strict required status checks"
  type        = bool
  default     = true
}

variable "required_status_check_contexts" {
  description = "List of required status check contexts (e.g. [\"ci/test\"])"
  type        = list(string)
  default     = []
}

variable "dismiss_stale_reviews" {
  description = "Whether to dismiss stale pull request reviews on push"
  type        = bool
  default     = true
}

variable "require_code_owner_reviews" {
  description = "Whether to require CODEOWNERS reviews"
  type        = bool
  default     = true
}

variable "required_approving_review_count" {
  description = "Number of required approving reviews"
  type        = number
  default     = 1
}
