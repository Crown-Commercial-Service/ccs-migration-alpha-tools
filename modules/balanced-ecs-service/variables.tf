variable "aws_account_id" {
  type        = string
  description = "ID of the account into which deployments are performed"
}

variable "aws_region" {
  type        = string
  description = "Region for resource deployment"
}

variable "container_cpu" {
  type        = number
  description = "CPU to allocate to each task container (where a value of 1024 == 1vCPU)"
}

variable "container_environment_variables" {
  type        = list(map(string))
  description = "Environment variables to be made available to service container tasks"
}

variable "container_healthcheck_command" {
  type        = string
  description = "Command to run within container to verify process health"
  default     = null
}

variable "container_memory" {
  type        = number
  description = "Memory to allocate to each task container (where a value of 1024 == 1GB)"
}

variable "container_port" {
  type        = number
  description = "Port on which container processes receives requests"
  default     = 80
}

variable "desired_count" {
  type        = number
  description = "Target number of instances of service to run (fixed)"
}

variable "ecs_cluster_arn" {
  type        = string
  description = "ARN of cluster into which service is to be deployed"
}

variable "ecs_execution_role_arn" {
  type        = string
  description = "ARN of the role which is assumed by the ECS execution processes"
}

variable "image" {
  type        = string
  description = "Canonical Docker image name - OR - URL of the image repo"
}

variable "lb_target_group_arn" {
  type        = string
  description = "ARN of the Load Balancer Target Group with which instances of this service should register"
}

variable "resource_name_prefixes" {
  type = object({
    normal        = string,
    hyphens       = string,
    hyphens_lower = string
  })
  description = "Prefix to apply to resources in AWS; options provided to satisfy divergent naming requirements across AWS"
}

variable "security_group_ids" {
  type        = list(string)
  description = "IDs of security groups to which the service tasks should be added"
}

variable "secret_environment_variables" {
  type        = list(map(string))
  description = "Environment variables to be looked up as secrets and then made available to each task container"
  default     = []
}

variable "service_name" {
  type        = string
  description = "Name of the service, indicating its purpose"
}

variable "service_subnet_ids" {
  type        = list(string)
  description = "IDs of the subnets in which to run the ECS tasks"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC containing the service"
}
