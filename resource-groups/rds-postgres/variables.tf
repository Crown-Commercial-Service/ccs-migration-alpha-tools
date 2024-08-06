variable "allocated_storage_gb" {
  type        = number
  description = "Storage allocation in GiB"
  default     = 10
}

variable "allow_major_version_upgrade" {
  type        = bool
  description = "Opt to allow major version upgrade (defaults to false"
  default     = false
}

variable "apply_immediately" {
  type        = bool
  description = "Whether to apply changes immediately or in the next maintenance window"
  default     = false
}

variable "auto_minor_version_upgrade" {
  type        = bool
  description = "Opt to enable automatic minor version upgrades"
  default     = false
}

variable "backup_retention_period_days" {
  type        = number
  description = "Number of days for which to keep backups"
  default     = 14
}

variable "ca_cert_identifier" {
  type        = string
  description = "The identifier of the CA certificate for the DB instance."
  default     = "rds-ca-2019"
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

variable "deletion_protection" {
  type        = bool
  description = "Boolean to opt in/out of enabling deletion protection. The DB cannot be deleted when set to true"
  default     = false
}

variable "final_snapshot_identifier" {
  type        = string
  description = "Identifier to give the final snapshot of the db upon deletion (if any)"
  default     = "final-snapshot"
}

variable "iam_database_authentication_enabled" {
  description = "Whether to enable IAM database authentication"
  type        = bool
  default     = false
}

variable "monitoring_interval" {
  type        = number
  default     = 0
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. 0 is disabled"
}

variable "monitoring_role_arn" {
  type        = string
  default     = null
  description = "ARN of IAM role for Enhanced Monitoring"
}

variable "parameter_group_name" {
  type        = string
  default     = null
  description = "Name of Parameter Group to use"
}

variable "performance_insights_enabled" {
  type        = bool
  default     = false
  description = "Whether to enable Performance Insights"
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

variable "rds_event_subscription_categories" {
  type        = list(string)
  description = "The list of event categories for a SourceType that you want to subscribe to"
  default     = ["maintenance"]
}

variable "rds_event_subscription_email_endpoint" {
  type        = string
  description = "The email address to send RDS Event Subscription notifications to"
}

variable "rds_event_subscription_enabled" {
  type        = bool
  description = "Boolean to determine whether or not to enable RDS Event Subscription (defaults to false)"
  default     = false
}

variable "rds_maintenance_window" {
  type        = string
  description = "The window in which RDS Maintenance should be performed (if enabled)"
  default     = "Wed:00:00-Wed:03:00"
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
  default     = null
}

variable "storage_throughput" {
  type        = number
  description = "Storage throughput in MiBps"
  default     = null
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
