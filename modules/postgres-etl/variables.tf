variable "aws_account_id" {
  type        = string
  description = "ID of the account into which deployments are performed"
}

variable "aws_region" {
  type        = string
  description = "Region for resource deployment"
}

variable "ecs_cluster_arn" {
  type        = string
  description = "ARN of cluster into which tasks will be deployed"
}

variable "extract_task_cpu" {
  type        = number
  default     = 8192
  description = "CPU resource to allocate to the extract task, in millicores"
}

variable "extract_task_memory" {
  type        = number
  default     = 16384
  description = "Memory resource to allocate to the extract task, in MiB"
}

variable "migrator_name" {
  description = "A name to distinguish this migrator"
  type        = string
}

variable "postgres_docker_image" {
  type        = string
  default = "postgres:12.20-alpine3.20"
  description = "Canonical name of the Docker image from which to run psql"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket to use for the Terraform state file"
  type        = string
}

variable "source_db_connection_url_ssm_param_arn" {
  type        = string
  description = "ARN of SSM param which contains the connection URL for the source Postgres database"
}

variable "subnet_id" {
  type        = string
  description = "ID of the subnet in which to run the download/restore ECS tasks and also in which to present the EFS mount point"
}
