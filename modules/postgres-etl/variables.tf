variable "aws_region" {
  type        = string
  description = "Region for resource deployment"
}

variable "enable_extract" {
  type        = bool
  description = "Whether to enable the extract task"
}

variable "enable_load" {
  type        = bool
  description = "Whether to enable the load task"
}

variable "environment_name" {
  type        = string
  description = "Name of the environment in which the migrator is running"
}

variable "source_db_connection_url_ssm_param_arn" {
  type        = string
  description = "ARN of SSM param which contains the connection URL for the source Postgres database"
}

variable "destination_db_connection_url_ssm_param_arn" {
  type        = string
  description = "ARN of SSM param which contains the connection URL for the source Postgres database"
}
