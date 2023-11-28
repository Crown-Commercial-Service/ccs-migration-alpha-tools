output "task_definition_arn" {
  description = "ARN of the task definition"
  value       = aws_ecs_task_definition.task.arn
}

output "task_family_name" {
  description = "Family name for the task"
  value       = aws_ecs_task_definition.task.family
}

output "task_role_arn" {
  description = "ARN of the IAM role assigned to all tasks run under this task definition"
  value       = aws_iam_role.task_role.arn
}

output "task_role_name" {
  description = "Name of the IAM role assigned to all tasks run under this task definition"
  value       = aws_iam_role.task_role.name
}
