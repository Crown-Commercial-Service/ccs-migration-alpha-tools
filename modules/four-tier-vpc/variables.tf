variable "aws_region" {
  type        = string
  description = "Region into which to deploy region-specific resources"
}

variable "resource_name_prefixes" {
  type = object({
    normal        = string,
    hyphens       = string,
    hyphens_lower = string
  })
  description = "Prefix to apply to resources in AWS; options provided to satisfy divergent naming requirements across AWS"
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block to assign to the VPC"
}
