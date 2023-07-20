variable "aws_region" {
  type        = string
  description = "Region into which to deploy region-specific resources"
}

variable "database_ports" {
  type = list(object({
    db_type : string
    port : number
  }))
  description = "List of objects, each list member detailing a port on which to allow traffic into the database subnet"
  # Example: database_ports = [ { db_type : "postgres", port : 5432 }, { db_type : "redis", port : 6379 } ]
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
