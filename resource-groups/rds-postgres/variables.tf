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

# TODO It's beyond the scope of an Alpha to manage final snapshot preferences - Leaving this here as a reminder.
variable "skip_final_snapshot" {
  type        = bool
  description = "Whether or not to allow the DB to be deleted without taking a snapshot"
  default     = true
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of IDs of subnets for DB subnet groups"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC containing the service"
}
