variable "is_ephemeral" {
  type        = bool
  description = "If set to true, indicates that this module is expected to be destroyed as a matter of course (so will set `force_destroy` on aws resources where appropriate)"
  default     = false
}

variable "repository_names" {
  type        = list(string)
  description = "List of names for the repositories to create"
}
