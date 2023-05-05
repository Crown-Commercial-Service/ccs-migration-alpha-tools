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
  description = "Environment variables to be made available to each task container"
  default     = []
}

variable "container_healthcheck_command" {
  type        = string
  description = "Command to run within container to verify process health"
  default     = null
}

variable "container_log_group_name" {
  type        = string
  description = "Name to give to the CloudWatch log group to which the task containers will write their standard (non-application) logs"
}

variable "container_memory" {
  type        = number
  description = "Memory to allocate to each task container (where a value of 1024 == 1GB)"
}

variable "container_name" {
  type        = string
  description = "Short name to give to the task containers"
}

variable "container_port" {
  type        = number
  description = "Port to which each task container expects to bind its listener"
  default     = null
}

variable "ecs_execution_role_arn" {
  type        = string
  description = "ARN of the role which is assumed by the ECS execution processes"
}

variable "efs_mounts" {
  type = list(object({
    access_point_id = string
    file_system_id  = string
    mount_point     = string
    read_only       = bool
    volume_name     = string
  }))
  description = "List of config value objects for EFS volumes to be mounted from the container"
  default     = []
}

variable "family_name" {
  type        = string
  description = "The name to give to the task definition, across all revisions"
}

variable "image" {
  type        = string
  description = "Canonical Docker image name - OR - URL of the image repo"
}

variable "override_command" {
  type        = list(string)
  description = "Startup command to override that which is specified in the original Dockerfile of the container"
  default     = null
}

variable "secret_environment_variables" {
  type        = list(map(string))
  description = "Environment variables to be looked up as secrets and then made available to each task container"
  default     = []
}
