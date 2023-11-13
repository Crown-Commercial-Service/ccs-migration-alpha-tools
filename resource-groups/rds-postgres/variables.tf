variable "allocated_storage_gb" {
  type        = number
  description = "Storage allocation in GiB"
  default     = 10
}

variable "backup_retention_period_days" {
  type        = number
  description = "Number of days for which to keep backups"
  default     = 14
}

variable "db_instance_class" {
  type        = string
  description = "Type of DB instance"
  default     = "db.t3.small"
}

variable "db_name" {
  type        = string
  description = "Short, no-spaces version of database name"
}

variable "db_username" {
  type        = string
  description = "Username for master user"
}

variable "final_snapshot_identifier" {
  type        = string
  description = "Identifier to give the final snapshot of the db upon deletion (if any)"
  default     = "final-snapshot"
}

variable "postgres_engine_version" {
  type        = string
  description = "Version number of db engine to use"
  default     = "14.6"
}

variable "postgres_port" {
  type        = number
  description = "Port on which the DB should accept connections"
  default     = 5432
}

variable "resource_name_prefixes" {
  type = object({
    normal        = string,
    hyphens       = string,
    hyphens_lower = string
  })
  description = "Prefix to apply to resources in AWS; options provided to satisfy divergent naming requirements across AWS"
}

variable "skip_final_snapshot" {
  type        = bool
  description = "Whether or not to allow the DB to be deleted without taking a snapshot"
  default     = false
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of IDs of subnets for DB subnet groups"
}

variable "storage_iops" {
  type        = number
  description = "Storage provisioned IOPS"
  default     = 0
}

variable "storage_type" {
  type        = string
  description = "Storage type"
  default     = "gp3"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC containing the service"
}
