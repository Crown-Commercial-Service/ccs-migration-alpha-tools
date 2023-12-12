variable "resources" {
  default     = []
  description = "HCL representation of the JSON"
  type        = set(map(any))
}
