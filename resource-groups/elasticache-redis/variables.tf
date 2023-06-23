variable "cluster_id" {
  type        = string
  description = "ID (name) to give"
  validation {
    condition     = can(regex("[a-z0-9\\-]+", var.cluster_id))
    error_message = "The cluster_id can only contain lower case a-z, 0-9 and hyphens(-)"
  }
}

variable "engine_version" {
  type        = string
  description = "Version of Redis engine"
  default     = "6.2"
}

variable "node_type" {
  type        = string
  description = "Type of node to deploy for the cachr"
  default     = "cache.t2.small"
}

variable "num_cache_nodes" {
  type        = number
  description = "Number of cache nodes to instantiate"
  default     = 1
}

variable "resource_name_prefixes" {
  type = object({
    normal        = string,
    hyphens       = string,
    hyphens_lower = string
  })
  description = "Prefix to apply to resources in AWS; options provided to satisfy divergent naming requirements across AWS"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of IDs of subnets into which to deploy the Elasticache cluster"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC containing the service"
}
