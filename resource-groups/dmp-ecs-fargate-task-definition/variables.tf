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
    cpu                   = number
    # Environment variables to be made available to the container
    environment_variables = list(map(string))
    # Indicates whether or not the container is essential to the task
    essential             = bool
    # Command to run within container to verify process health
    healthcheck_command   = string
    # Canonical Docker image name - OR - URL of the image repo
    image                 = string
    # Full name of an existing CloudWatch Log Group for the container
    log_group_name        = string
    # Memory to allocate to the container (where a value of 1024 == 1GB)
    memory                = number
    # List of config value objects for volumes to be mounted from the container
    mounts                = list(object({
      mount_point = string
      read_only   = bool
      volume_name = string
    }))
    # Startup command to override that which is specified in the original Dockerfile of the container
    override_command             = list(string)
    # Port to which the container expects to bind its listener
    port                         = number
    # Environment variables to be looked up as secrets and then made available to the container
    secret_environment_variables = list(map(string))
  }))
}

variable "ecs_execution_role_arn" {
  type        = string
  description = "ARN of the role which is assumed by the ECS execution processes"
}

variable "family_name" {
  type        = string
  description = "The family name to give to the task definition, across all revisions"
}

variable "override_entrypoints" {
  type        = map(list(string))
  description = "Forced override of entrypoint for the container"
  default     = {}
}

variable "task_cpu" {
  type        = number
  description = "CPU to allocate to each task (where a value of 1024 == 1vCPU) - Must be >= total of all containers' CPU"
}

variable "task_memory" {
  type        = number
  description = "Memory to allocate to each task (where a value of 1024 == 1GB) - Must be >= total of all containers' memory"
}

variable "task_name" {
  type        = string
  description = "The name to give to the task definition, across all revisions"
}

variable "volumes" {
  type = list(object({
    access_point_id = string
    file_system_id  = string
    volume_name     = string
  }))
  description = "List of volumes made available to the task's container(s)"
  default     = []
}
