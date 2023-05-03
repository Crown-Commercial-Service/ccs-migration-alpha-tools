output "ecs_service_arn" {
  description = "ARN of the ECS service"
  value       = aws_ecs_service.service.id
}

output "pass_task_role_policy_document_json" {
  description = "JSON describing an IAM policy which allows passage of the task role"
  value       = module.service_task_definition.pass_task_role_policy_document_json
}

output "task_role_arn" {
  description = "ARN of the IAM role assigned to all tasks run under this service"
  # Note this assumes that if there are multiple tasks, they all share the same task role
  value       = module.service_task_definition.task_role_arn
}

output "write_container_logs_policy_document_json" {
  description = "JSON describing an IAM policy which allows the container logs to be written to"
  value       = module.container_log_group.write_log_group_policy_document_json
}
