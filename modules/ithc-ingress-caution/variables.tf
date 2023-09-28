variable "database_subnet_az_ids" {
  type        = map(string)
  description = "Map of database subnet IDs keyed by AZ suffix"
}

variable "database_subnet_cidr_blocks" {
  type        = map(string)
  description = "Map of database CIDR blocks keyed by AZ suffix"
}

variable "database_subnets_nacl_id" {
  type        = string
  description = "The ID of the existing NACL for database subnets"
}

variable "db_bastion_instance_public_key" {
  type        = string
  description = "Single-line public key (e.g. 'ssh-ed25519 AAAAver3rbrbr')"
}

variable "db_bastion_instance_root_device_size_gb" {
  type        = number
  description = "Required size in GB of the root device for the DB Bastion instance"
}

variable "db_bastion_instance_type" {
  type        = string
  description = "Instance type for the DB Bastion instance"
}

variable "db_bastion_instance_subnet_cidr_block" {
  type        = string
  description = "CIDR block of the subnet for the DB Bastion instance - probably a public one"
}

variable "db_bastion_instance_subnet_id" {
  type        = string
  description = "ID of the subnet for the DB Bastion instance - probably a public one"
}

variable "db_clients_security_group_ids" {
  # List because some apps have > 1 Postgres database
  type        = list(string)
  description = "List of IDs of the DB Clients security groups set up for the original app"
}

# See naming convention doc:
#   https://crowncommercialservice.atlassian.net/wiki/spaces/GPaaS/pages/3561685032/AWS+3+Tier+Reference+Architecture
variable "ithc_operative_cidr_safelist" {
  type        = list(string)
  description = "List of CIDR ranges to be allowed to access the EC2 instances"
}

variable "public_subnets_nacl_id" {
  type        = string
  description = "The ID of the existing NACL for public subnets"
}

variable "resource_name_prefixes" {
  type = object({
    normal        = string,
    hyphens       = string,
    hyphens_lower = string,
  })
  description = "Prefix to apply to resources in AWS; options provided to satisfy divergent naming requirements across AWS"
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block of the VPC"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"
}

variable "vpc_scanner_instance_public_key" {
  type        = string
  description = "Single-line public key (e.g. 'ssh-ed25519 AAAAver3rbrbr')"
}

variable "vpc_scanner_instance_root_device_size_gb" {
  type        = number
  description = "Required size in GB of the root device for the VPC Scanner instance"
}

variable "vpc_scanner_instance_subnet_id" {
  type        = string
  description = "ID of the subnet for the VPC Scanner instance - probably a public one"
}

variable "vpc_scanner_instance_type" {
  type        = string
  description = "Instance type for the VPC Scanner instance"
}
