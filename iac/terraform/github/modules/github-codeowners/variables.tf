variable "repository" {
  description = "The name of the repository where the CODEOWNERS file will be managed."
  type        = string
}

variable "branch" {
  description = "Branch name pattern to protect (default: main)"
  type        = string
  default     = "main"
}

variable "github_owner" {
  description = "The GitHub organization or user that owns the repository."
  type        = string
}

variable "admins" {
  description = "List of GitHub usernames who are admins."
  type        = list(string)
  default     = []
}

variable "owners" {
  description = "List of GitHub usernames who are owners."
  type        = list(string)
  default     = []
}

variable "extra_rules" {
  description = <<-EOT
    Optional map of additional CODEOWNERS rules.
    Keys are file path patterns (like '/frontend/*'), values are GitHub usernames or handles.
    Example:
    {
      "/frontend/*" = "alice"
      "/backend/*"  = "bob"
    }
  EOT
  type        = map(string)
  default     = {}
}
