variable "aws_region" {
  default     = "eu-west-2"
  description = "Region into which to deploy region-specific resources"
  type        = string
}

variable "resources" {
  default     = []
  description = "HCL representation of the JSON"
  type        = set(map(any))
}

variable "start_schedule_enabled" {
  default     = true
  description = "value to enable or disable the start schedule"
  type        = bool
}
