variable "ecs_execution_role_arn" {
  type        = string
  description = "ARN of the ECS execution role which is responsible for setup and control of ECS tasks (NOT the task role)"
}

variable "service" {
  type = object({
    cluster         = string
    name            = string
    task_definition = string
  })
  description = "An aws_ecs_service resource which represents the service in whose guise the user is to run one-off commands"
}
