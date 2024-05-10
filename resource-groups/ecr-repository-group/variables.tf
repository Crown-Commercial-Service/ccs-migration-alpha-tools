variable "expire_untagged_images_older_than_days" {
  type        = number
  description = "Number of days after which to expire untagged images"
  default     = 14
}

variable "grant_jenkins_sandbox_access" {
  type        = bool
  description = "Boolean value to indicate whether or not to grant the Jenkins Sandbox instance access (defaults to false)"
  default     = false
}

variable "is_ephemeral" {
  type        = bool
  description = "If set to true, indicates that this module is expected to be destroyed as a matter of course (so will set `force_destroy` on aws resources where appropriate)"
  default     = false
}

variable "repository_names" {
  type        = list(string)
  description = "List of names for the repositories to create"
}
