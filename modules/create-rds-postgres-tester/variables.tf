variable "aws_account_id" {
  type        = string
  description = "ID of the account into which deployments are performed"
}

variable "aws_region" {
  type        = string
  description = "Region for resource deployment"
}

variable "db_clients_security_group_id" {
  type = string
  description = "ID of the security group that allows access to the RDS instance"
}

variable "db_name" {
  type        = string
  description = "Database name"
}

variable "load_task_cpu" {
  type        = number
  default     = 8192
  description = "CPU resource to allocate to the load task, in millicores"
}

variable "load_task_memory" {
  type        = number
  default     = 16384
  description = "Memory resource to allocate to the load task, in MiB"
}

variable "load_task_pgrestore_workers" {
  type        = number
  default     = 8
  description = "Number of pgrestore workers, one per CPU core"
}

variable "migrator_name" {
  description = "A name to distinguish this migrator"
  type        = string
}

variable "postgres_docker_image" {
  type        = string
  description = "Canonical name of the Docker image from which to run psql"
}

variable "resource_name_prefixes" {
  type = object({
    normal        = string,
    hyphens       = string,
    hyphens_lower = string
  })
  description = "Prefix to apply to resources in AWS; options provided to satisfy divergent naming requirements across AWS"
}

variable "rds_host" {
  type        = string
  description = "RDS host"
}

variable "subnet_id" {
  type        = string
  description = "ID of the subnet in which to run the extract/load ECS tasks and also in which to present the EFS mount point"
}

variable "target_db_connection_url_ssm_param_arn" {
  type        = string
  description = "ARN of SSM param which contains the connection URL for the target Postgres database"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC into which to deploy the resources"
}
