variable "aws_account_id" {
  type        = string
  description = "ID of the account into which deployments are performed"
}

variable "aws_region" {
  type        = string
  description = "Region for resource deployment"
}

variable "db_clients_security_group_id" {
  type        = string
  description = "ID of VPC security group, membership of which allows access to the Postgres db"
}

variable "db_etl_fs_clients" {
  type        = string
  description = "Entities permitted to access the EFS filesystem"
}

variable "ecs_cluster_arn" {
  type        = string
  description = "ARN of cluster into which tasks will be deployed"
}

variable "ecs_load_execution_role_arn" {
  type        = string
  description = "ARN of the role which is assumed by the ECS execution processes"
}

variable "ecs_load_execution_role_name" {
  type = string
  description = "Name of the role which is assumed by the ECS execution processes"
}

variable "efs_subnet_ids" {
  type        = set(string)
  default     = []
  description = "IDs of the subnest in which to create the EFS mount points"
}

variable "efs_access_point_id" {
  type        = string
  description = "ID of the EFS access point"
}

variable "efs_file_system_id" {
  type        = string
  description = "ID of the EFS file system"
}

variable "environment_name" {
  type        = string
  description = "Name of the environment in which the migrator is running"
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

variable "s3_load_bucket_name" {
  description = "Name of the S3 bucket to use for loading the Postgres DB for ETL purposes"
  type        = string
  default     = ""
}

variable "db_connection_url_ssm_param_arn" {
  type        = string
  description = "ARN of SSM param which contains the connection URL for the target Postgres database"
}

variable "subnet_ids" {
  type        = set(string)
  description = "IDs of the subnets in which to run the download/restore ECS tasks"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC in which to run the download/restore ECS tasks"
}
