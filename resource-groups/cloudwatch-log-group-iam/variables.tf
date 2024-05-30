variable "log_group_arns" {
  type        = set(string)
  default     = []
  description = "Log group names"
}
