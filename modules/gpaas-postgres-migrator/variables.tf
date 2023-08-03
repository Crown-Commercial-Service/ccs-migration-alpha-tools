variable "aws_account_id" {
  type        = string
  description = "ID of the account into which deployments are performed"
}

variable "aws_region" {
  type        = string
  description = "Region for resource deployment"
}

variable "cf_config" {
  type = object({
    api_endpoint        = string
    cf_cli_docker_image = string
    db_service_instance = string
    org                 = string
    space               = string
  })
  description = "Parameters for configuring the CloudFoundry interactions of this migrator's extract task"
}

variable "db_clients_security_group_id" {
  type        = string
  description = "ID of VPC security group, membership of which allows access to the Postgres db"
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

# The migration processes are singular - we don't need multi-AZ here
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
