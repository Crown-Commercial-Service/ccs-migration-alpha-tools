variable "aws_account_id" {
  type        = string
  description = "ID of the account into which deployments are performed"
}

variable "aws_region" {
  type        = string
  description = "Region for resource deployment"
}

variable "container_definitions" {
  type = map(object({
    # CPU to allocate to the container (where a value of 1024 == 1vCPU)
    cpu = number
    # Environment variables to be made available to the container
    environment_variables = list(map(string))
    # Indicates whether or not the container is essential to the task
    essential = bool
    # Command to run within container to verify process health
    healthcheck_command = string
    # Canonical Docker image name - OR - URL of the image repo
    image = string
    # Memory to allocate to the container (where a value of 1024 == 1GB)
    memory = number
    # List of config value objects for EFS volumes to be mounted from the container
    mounts = list(object({
      access_point_id = string
      file_system_id  = string
      mount_point     = string
      read_only       = bool
      volume_name     = string
    }))
    # Startup command to override that which is specified in the original Dockerfile of the container
    override_command = list(string)
    # Port to which the container expects to bind its listener
    port = number
    # Environment variables to be looked up as secrets and then made available to the container
    secret_environment_variables = list(map(string))
  }))
}

variable "desired_count" {
  type        = number
  description = "Target number of task instances of service to run (fixed)"
}

variable "ecs_cluster_arn" {
  type        = string
  description = "ARN of cluster into which service is to be deployed"
}

variable "ecs_execution_role_arn" {
  type        = string
  description = "ARN of the role which is assumed by the ECS execution processes"
}

variable "lb_target_group_arn" {
  type        = string
  description = "ARN of the Load Balancer Target Group with which instances of this service should register"
  default     = null
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

variable "service_container_name" {
  type        = string
  description = "The name of the container to which load balancers should direct traffic (required if this is a balanced service)"
  default     = null
}

variable "service_name" {
  type        = string
  description = "Name of the service, indicating its purpose"
}

variable "service_port" {
  type        = number
  description = "The port of the service container to which load balancers should direct traffic (required if this is a balanced service)"
  default     = null
}

variable "service_subnet_ids" {
  type        = list(string)
  description = "IDs of the subnets in which to run the ECS tasks"
}

variable "task_cpu" {
  type        = number
  description = "CPU to allocate to each task (where a value of 1024 == 1vCPU)"
}

variable "task_memory" {
  type        = number
  description = "Memory to allocate to each task (where a value of 1024 == 1GB)"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC containing the service"
}
