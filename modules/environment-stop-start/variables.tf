variable "resources" {
  default     = []
  description = "HCL representation of the JSON"
  type        = set(map(any))
}

variable "start_schedule_enabled" {
  default = true
  description = "value to enable or disable the start schedule"
  type = bool
}
