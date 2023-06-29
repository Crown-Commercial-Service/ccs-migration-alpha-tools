output "pass_task_role_policy_document_json" {
  description = "JSON describing an IAM policy which allows passage of the task role"
  value       = data.aws_iam_policy_document.pass_task_role.json
}

output "task_definition_arn" {
  description = "ARN of the task definition"
  value       = aws_ecs_task_definition.task.arn
}

output "task_role_arn" {
  description = "ARN of the IAM role assigned to all tasks run under this task definition"
  value       = aws_iam_role.task_role.arn
}

output "task_role_name" {
  description = "Name of the IAM role assigned to all tasks run under this task definition"
  value       = aws_iam_role.task_role.name
}

output "write_task_logs_policy_document_json" {
  description = "JSON describing an IAM policy which allows the task's log streams to be written"
  value       = module.task_log_group.write_log_group_policy_document_json
}
