variable "repository_name" {
  description = "Name of the GitHub repository."
  type        = string
}

variable "description" {
  description = "Description of the repository."
  type        = string
  default     = ""
}

variable "visibility" {
  description = "Visibility of the repository: public, private, or internal."
  type        = string
  default     = "private"
}

variable "topics" {
  description = "List of repository topics."
  type        = list(string)
  default     = []
}

variable "has_issues" {
  description = "Whether issues are enabled."
  type        = bool
  default     = true
}

variable "has_projects" {
  description = "Whether projects are enabled."
  type        = bool
  default     = false
}

variable "has_wiki" {
  description = "Whether wiki is enabled."
  type        = bool
  default     = false
}

variable "has_discussions" {
  description = "Whether discussions are enabled."
  type        = bool
  default     = false
}

variable "auto_init" {
  description = "Whether to initialize the repository with a README."
  type        = bool
  default     = true
}

variable "teams" {
  description = "Map of team slugs to permissions."
  type        = map(string)
  default     = {}
}

variable "external_team_ids" {
  description = "Optional map of team IDs keyed by team name. Use this if teams are created outside this module."
  type        = map(string)
  default     = {}
}
