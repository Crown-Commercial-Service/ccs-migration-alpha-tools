variable "aws_account_id" {
  type        = string
  description = "AWS account in which to deploy resources"
}

variable "aws_region" {
  type        = string
  description = "Region in which to deploy resources"
}

variable "cf_api_endpoint" {
  type        = string
  description = "URL of CF API endpoint from which to migrate Postgres data"
}

variable "cf_cli_docker_image" {
  type        = string
  description = "Canonical name of Docker image from which to run CF CLI client"
}

variable "cf_org" {
  type        = string
  description = "CF Org in which the original space resides"
}

variable "cf_password_ssm_param" {
  type        = string
  description = "Name of SSM parameter which contains the password of the CF account used to extract the data"
}

variable "cf_service_instance" {
  type        = string
  description = "Name of the CF Postgres service instance with which to communicate directly for the data"
}

variable "cf_space" {
  type        = string
  description = "CF Space in which the original data service resides"
}

variable "cf_username_ssm_param" {
  type        = string
  description = "Name of SSM parameter which contains the username of the CF account used to extract the data"
}

variable "db_clients_security_group_id" {
  type        = string
  description = "ID of VPC security group, membership of which allows access to the Postgres db"
}

variable "ecs_cluster_arn" {
  type        = string
  description = "ARN of cluster into which tasks will be deployed"
}

variable "ecs_execution_role_arn" {
  type        = string
  description = "ARN of the role which is assumed by the ECS execution processes"
}

variable "naming_prefix" {
  type        = string
  description = "Prefix to apply to names of all AWS resources"
}

variable "pass_ecs_execution_role_policy_arn" {
  type        = string
  description = "ARN of policy permitting passage of the ECS execution role"
}

variable "pg_db_endpoint" {
  type        = string
  description = "Endpoint of the Postgres DB in the format `host:port`"
}

variable "pg_db_name" {
  type        = string
  description = "Name of the Postgres DB"
}

variable "pg_db_password_ssm_param" {
  type        = string
  description = "Name of the SSM parameter which holds the database password"
}

variable "pg_db_username" {
  type        = string
  description = "Username for accessing the Postgres DB"
}

variable "pg_docker_image" {
  type        = string
  description = "Canonical name of Docker image from which to run Postgres psql utility"
}

variable "process_name" {
  type        = string
  description = "Short name for the process facilitated by this module - used in resource naming"
}

variable "subnets" {
  type        = map(string)
  description = "Map of IDs of subnets for resources in the form {AZ = ID}"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC in which to create the subnets"
}
