variable "aws_account_id" {
  type        = string
  description = "ID of the account into which deployments are performed"
}

variable "aws_region" {
  type        = string
  description = "Region for resource deployment"
}

variable "create_rds_postgres_tester_task_cpu" {
  type        = number
  default     = 256 # 0.25 vCPU
  description = "CPU resource to allocate to the load task, in millicores"
}

variable "create_rds_postgres_tester_task_memory" {
  type        = number
  default     = 512 # 0.5GB
  description = "Memory resource to allocate to the load task, in MiB"
}

variable "db_connection_url_ssm_param_arn" {
  type        = string
  description = "ARN of SSM param which contains the connection URL for the Postgres database"
}

variable "db_name" {
  type        = string
  description = "Database name"
}

variable "ecs_cluster_arn" {
  type        = string
  description = "ARN of cluster into which tasks will be deployed"
}

variable "ecs_execution_role" {
  type = object({
    arn  = string
    name = string
  })
  description = "Details of the role which is assumed by the ECS execution processes"
}

variable "postgres_docker_image" {
  type        = string
  description = "Canonical name of the Docker image from which to run psql"
}

variable "security_group_ids" {
  type        = set(string)
  description = "IDs of the security groups that will be assigned to the network interface"
}

variable "subnet_id" {
  type        = string
  description = "ID of the subnet in which to run the extract/load ECS tasks and also in which to present the EFS mount point"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC into which to deploy the resources"
}
